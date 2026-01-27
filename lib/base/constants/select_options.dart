class SelectOptions {
  final String label;
  final String value;
  const SelectOptions({required this.label, required this.value});
}

const vehicleCategoryOptions = <SelectOptions>[
  SelectOptions(label: 'Bus', value: 'Bus'),
  SelectOptions(label: 'Passanger', value: 'Passanger'),
  SelectOptions(label: 'Truck', value: 'Truck'),
  SelectOptions(label: 'Chiller', value: 'Chiller'),
  SelectOptions(label: 'Freezer', value: 'Freezer'),
  SelectOptions(label: 'Chiller & Freezer', value: 'Chiller & Freezer'),
  SelectOptions(label: 'Freezer & Chiller', value: 'Freezer & Chiller'),
];

const deviceTypeOptions = <SelectOptions>[
  SelectOptions(label: 'Teltonika', value: 'TELTONIKA'),
  SelectOptions(label: 'Concox', value: 'CONCOX'),
  SelectOptions(label: 'Ruptela', value: 'RUPTELA'),
];

const deviceModelOptions = <SelectOptions>[
  SelectOptions(label: 'FMB130', value: 'FMB130'),
  SelectOptions(label: 'FMB120', value: 'FMB120'),
];
