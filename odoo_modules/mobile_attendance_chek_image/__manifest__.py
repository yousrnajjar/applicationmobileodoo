# -*- coding: utf-8 -*-
{
    'name': "Vérification des images lors du pointage",

    'summary': """
        Permet de vérifier l'image lors du pointage""",

    'description': """
Permet de vérifier l'image lors du pointage
=================================================
    """,

    'author': "@jp-sft",
    'website': "http://www.yourcompany.com",

    'category': 'Mobile',
    'version': '0.1',
    'depends': ['base', 'mobile_attendance_image_gps'],
    'data': [
        'hr_attendance.xml'
    ],
    # dependence pip install face_recognition
    'external_dependencies': {
        'python': ['face_recognition'],
    },
}
