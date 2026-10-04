from flask import Flask, jsonify
import os
import datetime

app = Flask(__name__)
BUILD = os.getenv("BUILD_ID", "dev-local")


@app.route("/")
def index():
    return jsonify(
        service="sentra-digital-batam",
        status="running",
        build=BUILD,
        time=datetime.datetime.now().isoformat(timespec="seconds"),
    )


@app.route("/health")
def health():
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    # Sengaja di-bind ke 127.0.0.1 (bukan 0.0.0.0) demi keamanan pada
    # jaringan laboratorium bersama. Port dibaca dari environment agar
    # skrip otomasi (setup.sh) dapat mengatur port secara dinamis.
    port = int(os.getenv("PORT", "5000"))
    app.run(host="127.0.0.1", port=port)
