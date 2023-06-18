enum TakePictureForExpenseWorkflow {
  // Initialisation
  notStarted,
  started,
  // Prise de la photo
  cameraShowed,
  pictureTaken,
  pictureValidated,
  pictureNotValidated,
  pictureCanceled,
  // Note de frais
  expenseSelected, // Une note de frais a été sélectionnée pour la photo
  expenseCreated, // Une note de frais a été créée pour la photo
  expenseCanceled, // La création ou la selection de la note de frais a été annulée
  expenseValidated, // La note de frais a été validée
  expenseNotValidated,
  // Envoi de la photo
  pictureSent,
  pictureNotSent,
  // Affichage du résultat
  resultShowed
}
