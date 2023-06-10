
import '../model_helper.dart';

class Expense extends OdooModelHelper {


  Expense(super.info);

  Expense.fromJson(super.info);

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  List<String> get allFields => ['quantity', 'product_uom_id', 'date', 'account_id', 'employee_id', 'currency_id', 'company_id', 'payment_mode', 'state', 'attachment_number', 'name', 'is_editable', 'is_ref_editable', 'product_id', 'unit_amount', 'product_uom_category_id', 'tax_ids', 'total_amount', 'reference', 'sheet_id', 'analytic_account_id', 'analytic_tag_ids', 'description', 'message_follower_ids', 'activity_ids', 'message_ids', 'message_attachment_count'];

  @override
  List<String> get defaultFieldNames => [];

  @override
  List<String> get displayFieldNames => [
        'description',
        'product_id',
        'unit_amount',
        'company_currency_id',
        'quantity',
        'total_amount',
        'payment_mode',
      ];

  @override
  Map<String, String> get onchangeSpec => {'state': '', 'attachment_number': '', 'name': '', 'is_editable': '', 'is_ref_editable': '', 'product_id': '1', 'unit_amount': '1', 'product_uom_category_id': '', 'quantity': '1', 'product_uom_id': '1', 'tax_ids': '1', 'total_amount': '', 'reference': '', 'date': '', 'account_id': '', 'employee_id': '1', 'sheet_id': '1', 'currency_id': '1', 'analytic_account_id': '', 'analytic_tag_ids': '', 'company_id': '1', 'payment_mode': '', 'description': '', 'message_follower_ids': '', 'activity_ids': '', 'message_ids': '', 'message_attachment_count': ''};

}

