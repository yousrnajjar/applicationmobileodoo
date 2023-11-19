import logging

import base64

import io
import requests

import uuid

import typing

from odoo import models, fields, exceptions

_logger = logging.getLogger(__name__)
_Models = dict(
    VGG_FACE='VGG-Face',
    FACENET="Facenet",
    FACENET_512="Facenet512",
    OPEN_FACE="OpenFace",
    DEEP_FACE="DeepFace",
    DEEP_ID="DeepID",
    DLIB="Dlib",
    ARC_FACE="ArcFace",
    S_FACE="SFace"
)

_Detector = dict(
    OPENCV="opencv",
    RETINAFACE="retinaface",
    MTCNN="mtcnn",
    SSD="ssd",
    DLIB="dlib",
    MEDIAPIPE="mediapipe",
    YOLOV_8="yolov8",
)

_Metric = dict(
    COSINE="cosine",
    euclidean="euclidean",
    euclidean_l2="euclidean_l2"
)


def find_threshold(model_name, distance_metric):
    base_threshold = {"cosine": 0.40, "euclidean": 0.55, "euclidean_l2": 0.75}

    thresholds = {
        "VGG-Face": {"cosine": 0.40, "euclidean": 0.60, "euclidean_l2": 0.86},
        "Facenet": {"cosine": 0.40, "euclidean": 10, "euclidean_l2": 0.80},
        "Facenet512": {"cosine": 0.30, "euclidean": 23.56, "euclidean_l2": 1.04},
        "ArcFace": {"cosine": 0.68, "euclidean": 4.15, "euclidean_l2": 1.13},
        "Dlib": {"cosine": 0.07, "euclidean": 0.6, "euclidean_l2": 0.4},
        "SFace": {"cosine": 0.593, "euclidean": 10.734, "euclidean_l2": 1.055},
        "OpenFace": {"cosine": 0.10, "euclidean": 0.55, "euclidean_l2": 0.55},
        "DeepFace": {"cosine": 0.23, "euclidean": 64, "euclidean_l2": 0.64},
        "DeepID": {"cosine": 0.015, "euclidean": 45, "euclidean_l2": 0.17},
    }

    threshold = thresholds.get(model_name, base_threshold).get(distance_metric, 0.4)

    return threshold


class FaceVerificationService(models.Model):
    _name = 'face_verification.service'

    _description = "Service de vérification de face"

    name = fields.Char()
    # Face Vérification
    raise_for_service_status = fields.Boolean(
        string="Erreur de status",
        help="Lève un exception quand un érreur lors de la vérification survient",
        default=True
    )
    raise_for_connection_error = fields.Boolean(
        string="Erreur de connection",
        help="Lève un exception quand le service n'est pas disponible",
        default=False
    )
    verif_service_url = fields.Char(
        string="URL du service de vérification",
        default="http://127.0.0.1:8000/verify"
    )
    model_name = fields.Selection(
        string="Models de vérification",
        selection=[(k, k) for k in _Models.values()],
        required=True, default='VGG-Face'
    )
    detector_backend = fields.Selection(
        string="Outils de détection de face",
        selection=[(k, k) for k in _Detector.values()],
        required=True, default='opencv'
    )
    distance_metric = fields.Selection(
        string="Métrique de distance",
        selection=[(k, k) for k in _Metric.values()],
        required=True, default='cosine'
    )
    align = fields.Boolean(
        string="Alignement avec les yeux",
        required=True, default=True,
        help="Alignement en fonction de la position des yeux"
    )
    enforce_detection = fields.Boolean(
        string="Renforcé la détection", default=False,
        help="""Si aucun visage n'a pu être détecté dans une image, alors ceci
        la fonction renverra une exception par défaut. Définissez ceci sur False pour ne pas avoir cette exception.
        Cela peut être pratique pour les images basse résolution."""
    )

    def compare_faces(
            self,
            employee_images: typing.List[typing.Tuple[bytes, str]],
            check_image: typing.Tuple[bytes, str]
    ) -> bool:
        """
        Permet de comparer les images
        """

        image_file, context_type = check_image
        ext = context_type.split('/')[1]
        files = [("image_file", (f"{uuid.uuid4()}.{ext}", io.BytesIO(base64.b64decode(image_file))))]
        for known_image_file, context_type in employee_images:
            ext = context_type.split('/')[1]
            files.append(
                ("known_image_files",
                 (f"{uuid.uuid4()}.{ext}", io.BytesIO(base64.b64decode(known_image_file)), f'image/{ext}'))
            )

        params = dict(
            model_name=self.model_name,
            detector_backend=self.detector_backend,
            distance_metric=self.distance_metric,
            align=self.align,
            enforce_detection=self.enforce_detection,
        )
        try:
            response = requests.post(
                self.verif_service_url,
                files=files,
                params=params
            )
        except requests.exceptions.ConnectionError:
            if self.raise_for_connection_error:
                raise exceptions.UserError(
                    f"Erreur lors de la vérification: Le service {self.name} est t'il démarré?"
                )
            else:
                return False

        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError:
            _logger.error("Response: %s", response.status_code)
            if self.raise_for_service_status:
                raise exceptions.UserError("Problème dans le serveur de reconnaissance d'image")
            else:
                return False

        result = response.json()
        # TODO: Add more data
        return result['verified']
