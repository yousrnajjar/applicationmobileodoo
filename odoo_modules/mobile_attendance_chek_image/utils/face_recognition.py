"""
@Description: 

@Author jp-sft
@Date 26/10/2023
@Time 06:38

"""

import base64
import binascii
import io
import logging

import face_recognition

_logger = logging.getLogger(__name__)


def str_bytes_to_file(str_bytes) -> io.BytesIO:
    """
    Permet de convertir un string en bytes
    """
    return io.BytesIO(base64.b64decode(str_bytes))


def compare_faces(employee_images: list[bytes], check_image: bytes):
    """
    Permet de comparer les images
    """
    try:
        employee_image_to_files = [
            str_bytes_to_file(employee_image)
            for employee_image in employee_images
        ]
        bytes_to_file2 = str_bytes_to_file(check_image)
    except binascii.Error:
        _logger.exception("Bad thing happened")
        return False

    employee_image_arrays = [
        face_recognition.load_image_file(employee_image_to_file)
        for employee_image_to_file in employee_image_to_files
    ]
    check_image_array = face_recognition.load_image_file(bytes_to_file2)

    try:
        employee_image_encodes = [
            face_recognition.face_encodings(employee_image_array)[0]
            for employee_image_array in employee_image_arrays
        ]

        check_image_encode = face_recognition.face_encodings(check_image_array)[0]
    except IndexError:
        _logger.warning("Not Face Found")
        return False
    res = face_recognition.compare_faces(
        employee_image_encodes,
        check_image_encode
    )
    return res[0]
