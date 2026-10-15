// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../utils/theme/shape_utils.dart';

class FormInput extends StatefulWidget {
  final String? iLabel;
  final TextEditingController? iController;
  final TextInputType iType;
  final AutovalidateMode? validationMode;
  final bool? isReadOnly;
  final bool? isLight;
  final bool? isEnabled;
  final bool? executeValueChange;
  final FormFieldValidator<String>? iValidator;
  final Function(String)? onChanged;
  final Function()? onValueChanged;
  final Function()? onTap;
  final Widget? prefix;
  final bool? isActive;
  final bool? isMultiline;
  final double bdRadius;
  final int maxInput;

  const FormInput({
    Key? key,
    this.iLabel = "",
    this.iType = TextInputType.text,
    this.iController,
    this.validationMode = AutovalidateMode.disabled,
    this.isReadOnly = false,
    this.isLight = false,
    this.isEnabled = true,
    this.executeValueChange = false,
    this.iValidator,
    this.onChanged,
    this.onValueChanged,
    this.onTap,
    this.prefix,
    this.isActive = true,
    this.isMultiline = false,
    this.bdRadius = 5,
    this.maxInput = 20000,
  }) : super(key: key);

  @override
  FormInputState createState() => FormInputState();
}

class FormInputState extends State<FormInput> {
  @override
  Widget build(BuildContext context) {
    final foreColor = inputForeColor(widget.isLight);

    return TextFormField(
      controller: widget.iController,
      keyboardType: widget.iType,
      autovalidateMode: widget.validationMode,
      validator: widget.iValidator,
      minLines: widget.isMultiline! ? 50 : 1,
      maxLines: widget.isMultiline! ? null : 1,
      enabled: widget.isEnabled,
      readOnly: widget.isReadOnly!,
      onTap: widget.onTap,
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.maxInput),
      ],
      decoration: outlinedInputDecoration(
        color: foreColor,
        radius: widget.bdRadius,
        label: widget.iLabel,
        prefixIcon: widget.prefix,
        suffixIcon: InkWell(
          onTap: () => widget.iController!.clear(),
          child: Icon(Icons.clear, color: foreColor),
        ),
        isDense: widget.isMultiline!,
        contentPadding: widget.isMultiline! ? null : const EdgeInsets.all(5),
      ),
      style: inputTextStyle(foreColor),
      onChanged: widget.onChanged,
    )
        .padding(all: 10);
  }
}
