"""
@Description:

@Author jp-sft
@Date 26/10/2023
@Time 06:38

"""
import typing
import base64
import io
import logging
import os
import requests
import tempfile
import uuid

from PIL import Image

_logger = logging.getLogger(__name__)

SERVICE_URL = "http://127.0.0.1:8000/verify"


def compare_faces_using_service(
        employee_images: typing.List[bytes],
        check_image: bytes,
        service_url = SERVICE_URL
) -> bool:
    """
    Permet de comparer les images
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        img = Image.open(io.BytesIO(base64.b64decode(check_image)))
        ext = img.format.lower()
        check_image_path = os.path.join(temp_dir, f"{uuid.uuid4()}.{ext}")
        img.save(check_image_path)
        employee_image_paths = []
        for employee_image in employee_images:
            img = Image.open(io.BytesIO(base64.b64decode(employee_image)))
            ext = img.format.lower()
            employee_image_path = os.path.join(temp_dir, f"{uuid.uuid4()}.{ext}")
            employee_image_paths.append(employee_image_path)
            img.save(employee_image_path)

        files = {
            "image_file": (os.path.basename(check_image_path), open(check_image_path, "rb"))
        }
        for employee_image_path in employee_image_paths:
            files["known_image_files"] = (os.path.basename(employee_image_path), open(employee_image_path, "rb"))

        response = requests.post(
            service_url,
            files=files,
        )

        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError:
            _logger.error("Response: %s", response.json())
            _logger.exception("Bad thing happened")
            return False

        resulat = response.json()
        _logger.info("Resultat: %s", resulat)
        return resulat["is_verified"]
