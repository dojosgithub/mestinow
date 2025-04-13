enum MedicationSeverity { high, medium, low }

class Medication {
  final String name;
  final String category;
  final List<String> examples;
  final String warning;
  final MedicationSeverity severity;

  const Medication({
    required this.name,
    required this.category,
    required this.examples,
    required this.warning,
    required this.severity,
  });

  static List<Medication> get medications => [
    Medication(
      name: 'Telithromycin',
      category: 'Antibiotic',
      examples: ['Telithromycin (Ketek®)'],
      warning:
          ' Antibiotic for community acquired pneumonia. Should not be used in MG. FDA black box warning.',
      severity: MedicationSeverity.high,
    ),
    Medication(
      name: 'Fluoroquinolones',
      category: 'Antibiotic',
      examples: [
        'ciprofloxacin (Cipro®, Proquin XR®)',
        'levofloxacin (Levaquin®)',
        'norfloxacin (Noroxin®)',
        'moxifloxacin (Avelox®)',
        'ofloxacin (Floxin®)',
        'gemifloxacin (Factive®)',
      ],
      warning:
          'Commonly prescribed broad-spectrum antibiotics with FDA black box warning. Use cautiously.',
      severity: MedicationSeverity.high,
    ),
    Medication(
      name: 'Botulinum toxin',
      category: 'Treatment',
      examples: ['Botox®', 'Myobloc®', 'Dysport®', 'Xeomin®'],
      warning: 'Avoid completely.',
      severity: MedicationSeverity.high,
    ),
    Medication(
      name: 'Magnesium',
      category: 'Intravenous',
      examples: ['Intravenous magnesium'],
      warning:
          'May cause or exacerbate MG. Potentially dangerous if given intravenously, and orally in case of renal failure. Use only if absolutely necessary.',
      severity: MedicationSeverity.high,
    ),
    Medication(
      name: 'D-penicillamine',
      category: 'Treatment',
      examples: ['D-penicillamine'],
      warning:
          'Used for Wilson disease and rarely for rheumatoid arthritis. Strongly associated with causing MG. Avoid.',
      severity: MedicationSeverity.high,
    ),
    Medication(
      name: "Quinine",
      category: 'Treatment',
      examples: ['quinine', 'quinidine', 'procainamide'],
      warning:
          'Occasionally used for leg cramps. Use prohibited except in malaria in US.',
      severity: MedicationSeverity.high,
    ),
    Medication(
      name: 'Aminoglycoside antibiotics',
      category: 'Antibiotic',
      examples: [
        'gentamicin',
        'neomycin',
        'streptomycin',
        'kanamycin',
        'tobramycin',
      ],
      warning: 'May worsen MG. Use cautiously if no alternative available.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Macrolide',
      category: 'Antibiotic',
      examples: [
        'erythromycin',
        'clarithromycin',
        'azithromycin (Z-Pak®,Zithromax®)',
      ],
      warning:
          'Commonly prescribed antibiotics for gram-positive bacterial infections. May worsen MG. Use cautiously, if at all.',
      severity: MedicationSeverity.medium,
    ),
    // Medication(
    //   name: 'Corticosteroids',
    //   category: 'Treatment',
    //   warning: 'Standard treatment for MG but may cause transient worsening within first two weeks.',
    //   severity: MedicationSeverity.medium,
    // ),
    Medication(
      name: 'Beta-blockers',
      category: 'Cardiovascular',
      examples: ['propranolol', 'timolol eyedrops (Timoptic®)'],
      warning: 'May worsen MG. Use cautiously.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Statins',
      category: 'Cholesterol',
      examples: [
        'simvastatin',
        'atorvastatin',
        'rosuvastatin',
        'fluvastatin',
        'lovastatin',
        'pitavastatin',
        'pravastatin',
        'simvastatin',
      ],
      warning:
          'May worsen or precipitate MG. Use cautiously at lowest dose needed.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Chelating agent',
      category: 'Treatment',
      examples: ['deferoxamine'],
      warning: 'May worsen MG. Use cautiously.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Interferon alfa',
      category: 'Treatment',
      examples: ['interferon alfa-2b'],
      warning: 'May cause or exacerbate MG. Use cautiously.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Iodinated contrast agents',
      category: 'Radiology',
      examples: ['Iodinated radiologic contrast agents'],
      warning: 'May exacerbate MG. Use cautiously and observe.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Procainamide',
      category: 'Treatment',
      examples: ['procainamide'],
      warning:
          'Used for irregular heart rhythm. May cause or exacerbate MG. Use cautiously.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Chloroquine',
      category: 'Treatment',
      examples: ['chloroquine', 'Aralen®'],
      warning:
          'Used for malaria and amoeba infections. May cause or exacerbate MG. Use cautiously.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Hydroxychloroquine',
      category: 'Treatment',
      examples: ['hydroxychloroquine', 'Plaquenil®'],
      warning:
          'Used for malaria, rheumatoid arthritis and lupus. May cause or exacerbate MG. Use cautiously.',
      severity: MedicationSeverity.medium,
    ),
    Medication(
      name: 'Immune Checkpoint Inhibitors',
      category: 'Treatment',
      examples: [
        'nivolumab',
        'pembrolizumab',
        'atezolizumab',
        'avelumab',
        'durvalumab',
        'ipilimumab',
      ],
      warning: 'In rare cases it may cause or exacerbate MG. Use cautiously.',
      severity: MedicationSeverity.low,
    ),
  ];
}
