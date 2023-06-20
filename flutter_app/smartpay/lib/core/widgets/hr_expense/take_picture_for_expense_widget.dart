import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/hr_expense/select_expense_widget.dart';
import 'package:smartpay/core/widgets/hr_expense/take_picture_for_expense_worflow.dart';
import 'package:smartpay/core/widgets/take_picture.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/expense.dart';

import 'expense_form.dart';

/// Take a picture for an expense
class TakePictureExpenseWidget extends StatefulWidget {
  final TakePictureForExpenseWorkflow workflow;
  final List<Expense> expenses;
  final Function(TakePictureForExpenseWorkflow) onWorkFlowChanged;

  // onAttachmentCreated
  final Function(int) onAttachmentCreated;

  const TakePictureExpenseWidget(
      {super.key,
      required this.workflow,
      required this.expenses,
      required this.onWorkFlowChanged,
      required this.onAttachmentCreated});

  @override
  State<TakePictureExpenseWidget> createState() =>
      _TakePictureExpenseWidgetState();
}

class _TakePictureExpenseWidgetState extends State<TakePictureExpenseWidget>
    with SingleTickerProviderStateMixin {
  TakePictureForExpenseWorkflow? _workflow;
  Expense? _expense;
  late List<Expense> _expenses;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _workflow = widget.workflow;
    _expenses = widget.expenses;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMessageOnTop(context),
        Expanded(
          child: _buildMain(context),
        ),
        _buildButtons(context),
      ],
    );
  }

  /// Build Message On Top
  /// Affiche le message en haut de la page
  ///
  Widget _buildMessageOnTop(BuildContext context) {
    String message = '';
    switch (_workflow) {
      case TakePictureForExpenseWorkflow.notStarted:
        message = 'Vous devez prendre une photo pour une note de frais';
        break;
      case TakePictureForExpenseWorkflow.started:
        message = 'Prenez une photo pour une note de frais';
        break;
      case TakePictureForExpenseWorkflow.cameraShowed:
        //return Container();
        message = 'Prenez une photo pour une note de frais';
        break;
      case TakePictureForExpenseWorkflow.pictureTaken:
        message = 'La photo a été prise';
        break;
      case TakePictureForExpenseWorkflow.pictureValidated:
        message = 'La photo a été validée';
        break;
      case TakePictureForExpenseWorkflow.pictureNotValidated:
        message = 'La photo n\'a pas été validée';
        break;
      case TakePictureForExpenseWorkflow.pictureCanceled:
        message = 'La photo a été annulée';
        break;
      case TakePictureForExpenseWorkflow.expenseSelected:
        message = 'Une note de frais a été sélectionnée';
        break;
      case TakePictureForExpenseWorkflow.expenseCreated:
        message = 'Une note de frais a été créée';
        break;
      case TakePictureForExpenseWorkflow.expenseCanceled:
        message =
            'La création ou la selection de la note de frais a été annulée';
        break;
      case TakePictureForExpenseWorkflow.expenseValidated:
        message = 'La note de frais a été validée';
        break;
      case TakePictureForExpenseWorkflow.expenseNotValidated:
        message = 'La note de frais n\'a pas été validée';
        break;
      case TakePictureForExpenseWorkflow.pictureSent:
        message = 'La photo a été envoyée';
        break;
      case TakePictureForExpenseWorkflow.pictureNotSent:
        message = 'La photo n\'a pas été envoyée';
        break;
      case TakePictureForExpenseWorkflow.resultShowed:
        message = 'Le résultat a été affiché';
        break;
      default:
        message = 'Vous devez prendre une photo pour une note de frais';
    }
    if (kDebugMode) {
      print(message);
    }
    return Container();
    /*Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );*/
  }

  /// Build Buttons
  /// Affiche les boutons en bas de la page
  ///
  Widget _buildButtons(BuildContext context) {
    switch (_workflow) {
      case TakePictureForExpenseWorkflow.notStarted:
        return Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.notStarted;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.started;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Commencer'),
                ),
              ],
            ));
      case TakePictureForExpenseWorkflow.started:
        return Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.notStarted;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.cameraShowed;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Prendre une photo'),
                ),
              ],
            )
            /*ElevatedButton(
            onPressed: () {
              setState(() {
                _workflow = TakePictureForExpenseWorkflow.cameraShowed;
                widget.onWorkFlowChanged(_workflow!);
              });
            },
            child: const Text('Prendre une photo'),
          ),*/
            );
      case TakePictureForExpenseWorkflow.cameraShowed:
        return Container();
      case TakePictureForExpenseWorkflow.pictureTaken:
        return Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _workflow =
                          TakePictureForExpenseWorkflow.pictureNotValidated;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Reprendre'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.pictureCanceled;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _workflow =
                          TakePictureForExpenseWorkflow.pictureValidated;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Valider'),
                ),
              ],
            ));
      case TakePictureForExpenseWorkflow.pictureValidated:
        return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // modal for create expense
                    ExpenseFormWidget.buildExpenseForm(
                      onCancel: () {
                        Navigator.pop(context, null);
                      },
                      afterSave: (Expense expense) {
                        Navigator.pop(context, expense);
                        
                      },
                    ).then((Widget createdForm) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => createdForm),
                      ).then((dynamic expense) {
                        print('TakePictureForExpenseWidget: expense created: $expense');
                        Expense? newExpense = expense as Expense?;
                        if (newExpense != null) {
                          setState(() {
                            _workflow =
                                TakePictureForExpenseWorkflow.expenseCreated;
                            _expenses.add(newExpense);
                            _expense = newExpense;
                            widget.onWorkFlowChanged(_workflow!);
                          });
                        } else {
                          setState(() {
                            _workflow = TakePictureForExpenseWorkflow.pictureValidated;
                                //TakePictureForExpenseWorkflow.expenseCanceled;
                            widget.onWorkFlowChanged(_workflow!);
                          });
                        }
                      });
                    });

                    /*Expense? newExpense = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => createdForm),
                    );
                    if (newExpense != null) {
                      setState(() {
                        _workflow =
                            TakePictureForExpenseWorkflow.expenseCreated;
                        _expenses.add(newExpense);
                        _expense = newExpense;
                        widget.onWorkFlowChanged(_workflow!);
                      });
                    } else {
                      setState(() {
                        _workflow =
                            TakePictureForExpenseWorkflow.expenseCanceled;
                        widget.onWorkFlowChanged(_workflow!);
                      });
                    }*/
                  },
                  child: const Text('Créer une note de frais'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.expenseCanceled;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Expense? selectedExpense = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => SelectExpenseWidget(
                              title:
                                  'Selectionner une note de frais pour la photo',
                              expenses: _expenses,
                              onCancel: (BuildContext selectionContext) {
                                Navigator.pop(selectionContext, null);
                              },
                              onSelect: (BuildContext selectionContext,
                                  Expense expense) {
                                Navigator.pop(selectionContext, expense);
                              })),
                    );
                    if (selectedExpense != null) {
                      setState(() {
                        _workflow =
                            TakePictureForExpenseWorkflow.expenseSelected;
                        _expense = selectedExpense;
                        widget.onWorkFlowChanged(_workflow!);
                      });
                    } else {
                      setState(() {
                        _workflow = TakePictureForExpenseWorkflow.pictureValidated;
                            //TakePictureForExpenseWorkflow.expenseCanceled;
                        widget.onWorkFlowChanged(_workflow!);
                      });
                    }
                  },
                  child: const Text('Sélectionner une note de frais'),
                ),
              ],
            ));
      case TakePictureForExpenseWorkflow.pictureNotValidated:
        return Container();
      case TakePictureForExpenseWorkflow.pictureCanceled:
        return Container();
      case TakePictureForExpenseWorkflow.expenseSelected:
        return Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _workflow =
                            TakePictureForExpenseWorkflow.pictureValidated;
                        widget.onWorkFlowChanged(_workflow!);
                      });
                    },
                    child: const Text('Non, une autre')),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.expenseCanceled;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _workflow =
                          TakePictureForExpenseWorkflow.expenseValidated;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Oui'),
                ),
              ],
            ));
      case TakePictureForExpenseWorkflow.expenseCreated:
        return Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        //_workflow =
                        //    TakePictureForExpenseWorkflow.expenseNotValidated;
                        _workflow =
                            TakePictureForExpenseWorkflow.pictureValidated;
                        widget.onWorkFlowChanged(_workflow!);
                      });
                    },
                    child: const Text('Non, une autre')),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _workflow = TakePictureForExpenseWorkflow.expenseCanceled;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _workflow =
                          TakePictureForExpenseWorkflow.expenseValidated;
                      widget.onWorkFlowChanged(_workflow!);
                    });
                  },
                  child: const Text('Oui'),
                ),
              ],
            ));
      case TakePictureForExpenseWorkflow.expenseCanceled:
        return Container();
      case TakePictureForExpenseWorkflow.expenseValidated:
        return Container();
      case TakePictureForExpenseWorkflow.expenseNotValidated:
        return Container();
      case TakePictureForExpenseWorkflow.pictureSent:
        return Container(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _workflow = TakePictureForExpenseWorkflow.resultShowed;
                widget.onWorkFlowChanged(_workflow!);
              });
            },
            child: const Text('Terminer'),
          ),
        );
      case TakePictureForExpenseWorkflow.pictureNotSent:
        return Container();
      case TakePictureForExpenseWorkflow.resultShowed:
        return Container(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Retour'),
          ),
        );
      default:
        return Container();
    }
  }

  /// Build Main
  /// Affiche le contenu principal de la page
  ///
  Widget _buildMain(BuildContext context) {
    /// Build Camera Showed
    switch (_workflow) {
      case TakePictureForExpenseWorkflow.notStarted:
        return Container();
      case TakePictureForExpenseWorkflow.started:
        return _buildStarted(context);
      case TakePictureForExpenseWorkflow.cameraShowed:
        return _buildCameraShowed(context);
      case TakePictureForExpenseWorkflow.pictureTaken:
        return _buildPictureTaken(context);
      case TakePictureForExpenseWorkflow.pictureValidated:
        return _buildPictureValidated(context);
      case TakePictureForExpenseWorkflow.pictureNotValidated:
        return _buildPictureNotValidated(context);
      case TakePictureForExpenseWorkflow.pictureCanceled:
        return _buildPictureCanceled(context);
      case TakePictureForExpenseWorkflow.expenseSelected:
        return _buildExpenseSelected(context);
      case TakePictureForExpenseWorkflow.expenseCreated:
        return _buildExpenseCreated(context);
      case TakePictureForExpenseWorkflow.expenseCanceled:
        return _buildExpenseCanceled(context);
      case TakePictureForExpenseWorkflow.expenseValidated:
        return _buildExpenseValidated(context);
      case TakePictureForExpenseWorkflow.expenseNotValidated:
        return _buildExpenseNotValidated(context);
      case TakePictureForExpenseWorkflow.pictureSent:
        return _buildPictureSent(context);
      case TakePictureForExpenseWorkflow.pictureNotSent:
        return _buildPictureNotSent(context);
      case TakePictureForExpenseWorkflow.resultShowed:
        return _buildResultShowed(context);
      default:
        return Container();
    }
  }

  /// Build Started
  /// Affiche processus de prise de photo bien détailé
  /// Le bouton sera affiché dans la fonction _buildButtons
  ///
  Widget _buildStarted(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(30),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prendre une photo de la note de frais',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Text(''),
            Text('1. Prendre la photo',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Text('2. Valider la photo',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Text(
                '3. Sélectionner la note de frais ou créer une nouvelle note de frais',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Text('4. Valider la note de frais',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Text('5. Envoyer la note de frais',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Text('6. Terminer',
                style: TextStyle(fontSize: 20, color: Colors.white)),
          ],
        ));
  }

  /// Build Camera Showed
  /// Affiche la caméra
  ///
  Widget _buildCameraShowed(BuildContext context) {
    return TakePictureScreen(
      onPictureTaken: (XFile file) {
        setState(() {
          _imageFile = file;
          _workflow = TakePictureForExpenseWorkflow.pictureTaken;
          widget.onWorkFlowChanged(_workflow!);
        });
      },
    );
  }

  /// Build Picture Taken
  /// Affiche la photo prise
  ///
  Widget _buildPictureTaken(BuildContext context) {
    /// Les boutons permettent de valider ou d'annuler la photo sont affichés dans la fonction _buildButtons
    return Image.file(File(_imageFile!.path), width: double.infinity);
  }

  /// Build Picture Validated
  /// Affiche la liste des notes de frais pour sélectionner celle dans laquelle la photo doit être enregistrée
  ///
  Widget _buildPictureValidated(BuildContext context) {
    return Image.file(File(_imageFile!.path), width: double.infinity);
    /*padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: SelectExpenseWidget(
            expenses: _expenses,
            onSelect: (BuildContext context, Expense expense) {
              setState(() {
                _expense = expense;
                _workflow = TakePictureForExpenseWorkflow.expenseSelected;
                widget.onWorkFlowChanged(_workflow!);
              });
            },
          ),
      );*/
    /*
SelectExpenseWidget(
      expenses: _expenses,
      onSelect: (BuildContext context, Expense expense) {
        setState(() {
          _expense = expense;
          _workflow = TakePictureForExpenseWorkflow.expenseSelected;
          widget.onWorkFlowChanged(_workflow!);
        });
      },
    );*/
  }

  /// Build Picture Not Validated
  /// Affiche de nouveau la caméra pour reprendre la photo
  ///
  Widget _buildPictureNotValidated(BuildContext context) {
    return _buildCameraShowed(context);
  }

  /// Build Picture Canceled
  /// Accun contenu à afficher
  ///
  Widget _buildPictureCanceled(BuildContext context) {
    return Container();
  }

  /// Build Expense Selected
  /// Demande à l'utilisateur de confirmer la note de frais sélectionnée
  ///
  Widget _buildExpenseSelected(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          'Voulez-vous enregistrer la photo dans cette note de frais ?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '${_expense!.info['name']}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kGreen,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Image.file(File(_imageFile!.path), width: double.infinity),
        ),
      ],
    );
    /*Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Text(
              'Voulez-vous enregistrer la photo dans la note de frais ${_expense!.info['name']} ?'),
          // photo
          Container(
            child: Image.file(File(_imageFile!.path), width: double.infinity),
          ),
        ],
      ),
    );*/
  }

  /// Build Expense Created
  /// Demande à l'utilisateur de confirmer la note de frais créée en indiquant qu'elle est vient d'être créée
  ///
  Widget _buildExpenseCreated(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          const Text(
            'Voulez-vous enregistrer la photo dans la nouvelle note de frais créer?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${_expense!.info['name']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kGreen,
            ),
          ),
          // photo
          Expanded(
            child: Image.file(File(_imageFile!.path), width: double.infinity),
          ),
        ],
      ),
    );
  }

  /// Build Expense Canceled
  /// Accun contenu à afficher
  ///
  Widget _buildExpenseCanceled(BuildContext context) {
    return Container();
  }

  /// Build Expense Validated
  /// Enregistre la photo comme attachment de la note de frais créée dans odoo
  ///
  Widget _buildExpenseValidated(BuildContext context) {
    if (kDebugMode) {
      print('Try to create attachment');
    }
    _imageFile!.readAsBytes().then((value) {
      var base64Document = base64Encode(value);
      Map<String, dynamic> attachment = {
        'name': _imageFile!.name,
        'datas': base64Document,
        'mimetype': _imageFile!.mimeType,
        'res_model': 'hr.expense',
        'res_id': _expense!.info['id'],
        'type': 'binary',
      };
      OdooModel.session.create('ir.attachment', attachment).then((response) {
        setState(() {
          widget.onAttachmentCreated(response);
          _workflow = TakePictureForExpenseWorkflow.pictureSent;
          widget.onWorkFlowChanged(_workflow!);
        });
      }).catchError((error) {
        if (kDebugMode) {
          print(error);
        }
        setState(() {
          _workflow = TakePictureForExpenseWorkflow.pictureNotSent;
          widget.onWorkFlowChanged(_workflow!);
        });
      });
    });
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build Expense Not Validated
  /// Retourne à l'étape précédente
  ///
  Widget _buildExpenseNotValidated(BuildContext context) {
    return _buildPictureValidated(context);
  }

  /// Build Picture Sent
  /// Affiche le message annimé d'attente de réponse du serveur
  ///
  Widget _buildPictureSent(BuildContext context) {
    var animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    var animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
    return Container(
      alignment: Alignment.center,
      child: FadeTransition(
        opacity: animation,
        child: const Text('Envoi de la photo en cours...'),
      ),
    );
  }

  /// Build Picture Not Sent
  /// Demande à l'utilisateur de réessayer
  ///
  Widget _buildPictureNotSent(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          const Text(
            'La photo n\'a pas pu être envoyée, voulez-vous réessayer ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Détailler de la note de frais
          const Text(
            'Note de frais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${_expense!.info['name']}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),

          // photo
          Expanded(
            child: Image.file(File(_imageFile!.path), width: double.infinity),
          ),
        ],
      ),
    );
  }

  /// Build Result Showed
  /// Jolie message pour indiquer que la photo a bien été enregistrée
  ///
  Widget _buildResultShowed(BuildContext context) {
    return Container();
    /*Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Text(
              'La photo a bien été enregistrée dans la note de frais ${_expense!.info['name']}'
            ),
          // photo
          Container(
            child: Image.file(File(_imageFile!.path), width: double.infinity),
          ),
        ],
      ),
    );*/
  }

  Future<Widget> buildCreatedForm(BuildContext ctx) async {
    return ExpenseFormWidget.buildExpenseForm(onCancel: () {
      Navigator.pop(ctx, null);
    }, afterSave: (Expense expense) {
      Navigator.pop(ctx, expense);
    });
  }
}
