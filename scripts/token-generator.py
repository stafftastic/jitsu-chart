import copy
import base64
import hashlib
import json
import os
import secrets
import subprocess
import sys
import yaml

SECRET_LENGTH = 32
TOKEN_LENGTH = 32
SALT_LENGTH = 32

def log(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def b64encode(s):
    return base64.b64encode(s.encode()).decode()

def b64decode(s):
    return base64.b64decode(s).decode()

def newSecret(fullname, labels):
    return {
        "apiVersion": "v1",
        "kind": "Secret",
        "metadata": {
            "name": f"{fullname}-tokens",
            "labels": labels,
        },
        "type": "Opaque",
        "data": {},
    }

def getSecret(fullname):
    proc = subprocess.run(
        [
            "kubectl",
            "get",
            "secret",
            f"{fullname}-tokens",
            "-o",
            "json"
        ],
        capture_output=True
    )
    if proc.returncode == 0:
        return json.loads(proc.stdout)
    return None 

def updateSecret(secret):
    proc = subprocess.run(
        [
            "kubectl",
            "apply",
            "-f",
            "-",
        ],
        input=json.dumps(secret).encode(),
    )

def generateTokenSet(service, globalHashSecret):
    token = secrets.token_urlsafe(TOKEN_LENGTH)
    salt = secrets.token_urlsafe(SALT_LENGTH)
    hash = hashlib.sha512(f"{token}{salt}{globalHashSecret}".encode()).hexdigest()
    if service == "console":
        token = f"service-admin-account:{token}"
    return {
        f"{service}AuthToken": b64encode(token),
        f"{service}AuthTokens": b64encode(f"{salt}.{hash}"),
    }

def validateTokenSet(service, token, hashes, globalHashSecret):
    if service == "console":
        prefix, token = token.split(":")[1]
        if prefix != "service-admin-account":
            raise ValueError
    for hash in hashes.split(","):
        salt, hash = hash.split(".")
        if hash == hashlib.sha512(f"{token}{salt}{globalHashSecret}".encode()).hexdigest():
            return
    raise ValueError

def __main__():
    services = [
        "bulker",
        "console",
        "ingest",
        "rotor",
        "syncctl",
    ]

    fullname = os.getenv("FULLNAME")
    labels = json.loads(os.getenv("LABELS"))

    secret = getSecret(fullname)
    originalSecret = copy.deepcopy(secret)
    if secret is None:
        log("No secret found, creating a new one...")
        secret = newSecret(fullname, labels)

    try:
        globalHashSecret = b64decode(secret["data"].get("globalHashSecret"))
    except:
        globalHashSecret = secrets.token_urlsafe(SECRET_LENGTH)
        secret["data"]["globalHashSecret"] = b64encode(globalHashSecret)

    for service in services:
        try:
            validateTokenSet(
                service,
                b64decode(secret["data"].get(f"{service}AuthToken")),
                b64decode(secret["data"].get(f"{service}AuthTokens")),
                globalHashSecret
            )
        except:
            log(f"Generating token for {service}...")
            secret["data"].update(generateTokenSet(service, globalHashSecret))

    if secret == originalSecret:
        log("No changes to secret.")
    else:
        log("Updating secret...")
        updateSecret(secret)


if __name__ == "__main__":
    __main__()
