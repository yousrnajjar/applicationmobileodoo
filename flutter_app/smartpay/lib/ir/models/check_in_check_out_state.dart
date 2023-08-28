enum CheckInCheckOutState {
  /// le salarié ne peut pas faire de check in ou check out car ce n'est pas l'heure
  /// A afficher:
  /// dans le header: DURÉE DE LA JOURNÉE DU TRAVAIL
  /// pas de subHeader1
  /// dans le subHeader2: DATE : 01/01/2021
  ///
  /// dans le startTime: DÉBUT D'ACTIVITÉ: 8:00
  /// dans le endTime: FIN D'ACTIVITÉ: 17:00
  ///
  /// workTime: 00:00:00
  /// pas de bouton DÉMARRER
  /// pas de footerHelpText
  hourNotReached,

  /// le salarié peut faire un check in
  /// A afficher:
  /// dans le header: MERCI DE POINTER
  /// dans le subHeader1: DÈS LE DÉMARRAGE DE VOTRE ACTIVITÉ
  /// dans le subHeader2: DATE : 01/01/2021
  ///
  /// pas de startTime
  /// pas de endTime
  ///
  /// dans le WorkTime: 00:00:00
  ///
  /// dans le bouton: DÉMARRER  --> (avec un accordion pour afficher le footerHelpText en dessous qui est affiché par défaut)
  /// footerHelpText: Cliquer pour pointer
  canCheckIn,

  /// le salarié peut faire un check out
  /// A afficher:
  /// dans le header: DURÉE DE LA JOURNÉE DU TRAVAIL
  /// pas de subHeader1
  /// dans le subHeader2: DATE : 01/01/2021
  ///
  /// dans le startTime: DÉBUT D'ACTIVITÉ: 8:00
  /// pas de endTime
  ///
  /// dans le WorkTime: 00:00:01 (qui s'incrémente chaque seconde)
  ///
  /// dans le bouton: CLOTURER LA JOURNÉE
  /// pas de footerHelpText
  canCheckOut
}
