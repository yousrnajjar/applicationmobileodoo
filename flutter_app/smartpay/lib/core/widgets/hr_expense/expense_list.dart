import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/hr_expense/expense_list_item.dart';
import 'package:smartpay/core/widgets/hr_expense/take_picture_for_expense_worflow.dart';
import 'package:smartpay/exceptions/core_exceptions.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/expense.dart';
import 'package:smartpay/ir/models/user.dart';

import 'select_expense_widget.dart';
import 'take_picture_for_expense_widget.dart';

class ExpenseList extends StatefulWidget {
  final User user;
  final Function(int) onChangedPage;

  const ExpenseList(
      {super.key, required this.user, required this.onChangedPage});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  bool _showAddExpenseWidget = false;
  TakePictureForExpenseWorkflow _takePictureWorkflow =
      TakePictureForExpenseWorkflow.cameraShowed;
  List<Expense> _loadedExpense = [];

  Future<List<Expense>> listenForExpenses() async {
    var result = await OdooModel('hr.expense').searchRead(
      domain: [
        ['employee_id', '=', widget.user.employeeId]
      ],
      fieldNames: Expense({}).allFields,
      limit: 1000,
    );
    var expenses = result.map((e) => Expense.fromJson(e)).toList();
    _loadedExpense = expenses;
    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    var addExpenseWidget = buildAddExpenseWidget(context);
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: buildExpenseList(context), // Expense List
        ),
        if (_showAddExpenseWidget == true && addExpenseWidget != null)
          // Ajoute un décoration légèrement grise transparente
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showAddExpenseWidget = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
        if (_showAddExpenseWidget == true && addExpenseWidget != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: addExpenseWidget,
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              //widget.onChangedPage(1);
              setState(() {
                _showAddExpenseWidget = !_showAddExpenseWidget;
              });
            },
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
            child: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ),
        // Take Picture Workflow Widget
        if (![
          TakePictureForExpenseWorkflow.notStarted,
          TakePictureForExpenseWorkflow.pictureCanceled,
          TakePictureForExpenseWorkflow.expenseCanceled,
          TakePictureForExpenseWorkflow.pictureSent,
          TakePictureForExpenseWorkflow.pictureValidated, // Because we need to create the expense when the picture is validated
        ].contains(_takePictureWorkflow))
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.9),
              alignment: Alignment.center,
              child: TakePictureExpenseWidget(
                workflow: _takePictureWorkflow,
                onAttachmentCreated: (int attachmentId) {
                  triggerNewAttachmentId(attachmentId);
                },
                onWorkFlowChanged: (workflow) {
                  print('ExpenseList: workflow changed $workflow');
                  setState(() {
                    _takePictureWorkflow = workflow;
                  });
                },
                onPictureValidated: (XFile f) {
                  _createExpenseFromAttachment(f).then((value) {
                    setState(() {
                      _takePictureWorkflow =
                          TakePictureForExpenseWorkflow.pictureValidated;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Note de frais $value créée'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  });
                },
                expenses: _loadedExpense,
              ),
            ),
          ),
      ],
    );
  }

  /// Trigger New Attachment Id
  Future<void> triggerNewAttachmentId(int attachmentId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attachment $attachmentId created'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Expense List
  /// Permet d'afficher la liste des expenses
  ///
  Widget buildExpenseList(BuildContext context,
      {Function(BuildContext, Map<String, dynamic>)? onExpenseTap}) {
    return FutureBuilder(
      future: listenForExpenses(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var expenses = snapshot.data!.map((e) => e.info).toList();
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return ExpenseListItem.fromMap(context, expenses[index],
                  onTap: () {
                if (onExpenseTap != null) {
                  onExpenseTap(context, expenses[index]);
                }
              });
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  /// Handle Expense Tap
  /// Permet de gérer le tap sur une expense
  /// Add Expense Widget
  /// Permet d'afficher un widget en bas pour choisir le type d'ajout d'expense
  /// Il a un padding important
  /// On a une liste de 3 actions possibles les une en dessous des autres
  /// 03 actions possibles a afficher tel quelles aves des icones
  /// 1. Capture une photo
  /// 2. Télécharger depuis le téléphone
  /// 3. Créer une spécifique
  Widget? buildAddExpenseWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 40,
        bottom: 60,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.camera_alt,
              color: kGreen,
            ),
            title: Text('Capturer une photo',
                style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              setState(() {
                _showAddExpenseWidget = false;
                _takePictureWorkflow = TakePictureForExpenseWorkflow.cameraShowed;
              });
              /*_takePicture(context);*/
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.cloud_upload,
              color: kGreen,
            ),
            title: Text('Télécharger depuis le téléphone',
                style: Theme.of(context).textTheme.bodyLarge),
            onTap: () async {
              int? docId = await _uploadDocument(context);
              if (context.mounted) {
                if (docId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aucun document n\'a été téléchargé'),
                    ),
                  );
                } else {
// Reload list
                    setState(() {
                      _showAddExpenseWidget = false;
                    });
                  ScaffoldMessenger.of(context).showSnackBar(
                    
                    const SnackBar(
                      content: Text('Document enregistré avec succès'),
                    ),
                  );

                }
              }
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add,
              color: kGreen,
            ),
            title: Text('Créer une spécifique',
                style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              widget.onChangedPage(1);
            },
          ),
        ],
      ),
    );
  }

  /// Upload Document
  /// Permet de télécharger un document depuis le téléphone
  /// On utilise file_picker
  ///
  Future<int?> _uploadDocument(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      // Enregistrer le document dans Odoo
      //return await _postDocument(file);
      try {
        return await _createExpenseFromAttachment(file);
      } catch (e) {
        print(e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune expense n\'a été sélectionnée'),
            ),
          );
        }
      }
    } else {
      return null;
    }
  }

  /// Post Picture
  /// Permet d'enregistrer une image dans Odoo
  /// Fonctionnement:
  /// 1. On récupère le fichier
  /// 2. On encode le fichier en base64
  /// 3. On l'associe à une expense
  /// 4. On enregistre le document dans Odoo
  Future<int> _postDocument(XFile file) async {
    var bytes = await file.readAsBytes();
    var base64Document = base64Encode(bytes);
    late Expense expense;
    try {
      expense = await _selectedExpense();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune expense n\'a été sélectionnée'),
          ),
        );
      }
      return 0;
    }
    Map<String, dynamic> attachment = {
      'name': file.name,
      'datas': base64Document,
      'mimetype': file.mimeType,
      'res_model': 'hr.expense',
      'res_id': expense.info['id'],
      'type': 'binary',
    };
    var res = await OdooModel.session.create('ir.attachment', attachment);
    return res;
  }

  // Create Expense from attachment
  // Permet de créer une expense depuis un document
  Future<int> _createExpenseFromAttachment(XFile file) async {
    var bytes = await file.readAsBytes();
    var base64Document = base64Encode(bytes);
    Map<String, dynamic> attachment = {
      'name': file.name,
      'datas': base64Document,
      'res_model': 'hr.expense',
      'mimetype': file.mimeType,
      'type': 'binary',
    };
    print("_createExpenseFromAttachment: create attachment");
    var attachmentId = await OdooModel.session.create('ir.attachment', attachment);
    print("_createExpenseFromAttachment: create expense");
    var res = await OdooModel.session.callKw({
      'model': 'hr.expense',
      'method': 'create_expense_from_attachments',
      'args': ["", [attachmentId]],
      'kwargs': {
        'context': OdooModel.session.defaultContext,
      },
    });
    print(res);
    try {
      return res['res_id'];
    } catch (e) {
      throw Exception('Impossible de créer une expense depuis le document');
    }
  } 
  

  /// Selected Expense
  /// Permet de choisir une expense
  /// Fonctionnement:
  /// 1. On affiche la liste des expenses
  /// 2. On attend le choix de l'utilisateur
  /// 3. On retourne l'expense choisie
  ///
  Future<Expense> _selectedExpense() async {
    var expenses = await listenForExpenses();
    Expense? expense;
    if (context.mounted) {
      expense = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => SelectExpenseWidget(
            expenses: expenses,
            onSelect: (selectedExpenseContext, expense) {
              Navigator.of(selectedExpenseContext).pop(expense);
            },
          ),
        ),
      );
    }
    if (expense == null) {
      throw NoExpenseSelectedException('Aucune dépense n\'a été choisie');
    } else {
      return expense;
    }
  }
}
