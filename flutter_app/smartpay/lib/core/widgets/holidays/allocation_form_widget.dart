import 'package:flutter/material.dart';
import 'package:smartpay/models/holidays_models.dart';

class FormulaireDemandeAllocation extends StatefulWidget {
  final List<HolidayType> holidaysStatus;

  const FormulaireDemandeAllocation({
    super.key,
    required this.holidaysStatus,
  });

  @override
  State<FormulaireDemandeAllocation> createState() =>
      _FormulaireDemandeAllocationState();
}

class _FormulaireDemandeAllocationState
    extends State<FormulaireDemandeAllocation> {
  final _formKey = GlobalKey<FormState>();

  String _nom = '';
  String _idStatutConge = '';
  String _affichageNombreJours = '';
  String _affichageNombreHeures = '';
  String _notes = '';
  HolidayType? _selectedHolidayType;

  final bool _estUniteRequeteHeureVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Expanded(
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
              onSaved: (value) {
                _nom = value!;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField(
                  value: _selectedHolidayType,
                  decoration:
                      const InputDecoration(label: Text("Type de congés")),
                  items: [
                    for (var type in widget.holidaysStatus)
                      DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedHolidayType = value;
                    });
                  }),
            ),
            Row(
              children: [
                Visibility(
                  visible: !_estUniteRequeteHeureVisible,
                  child: Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(label: Text("Durée")),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        // Logique de validation pour le champ Affichage du nombre de jours
                      },
                      onSaved: (value) {
                        _affichageNombreJours = value!;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Visibility(
                  visible: !_estUniteRequeteHeureVisible,
                  child: const Text('Jours'),
                ),
                Visibility(
                  visible: _estUniteRequeteHeureVisible,
                  child: const Text('Heures'),
                ),
              ],
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Ajouter un commentaire'),
              minLines: 5,
              maxLines: 8,
              onSaved: (value) {
                _notes = value!;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Logique pour soumettre les données du formulaire
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
