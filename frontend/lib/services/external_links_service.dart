import 'package:url_launcher/url_launcher.dart';

class ExternalLinksService {
  // General ECI & Govt Links
  static const String eciMain = 'https://eci.gov.in/';
  static const String govtMaharashtra = 'https://maharashtra.gov.in/';
  static const String secMaharashtra = 'https://mahasec.maharashtra.gov.in/';
  static const String nvsp = 'https://nvsp.in/';
  static const String voterPortal = 'https://voters.eci.gov.in/';
  static const String sveep = 'https://ecisveep.nic.in/';
  static const String downloadEepic = 'https://voters.eci.gov.in/';
  static const String voterSearch = 'https://electoralsearch.eci.gov.in/';
  static const String pdfElectoralRoll = 'https://voters.eci.gov.in/download-eroll?stateCode=S13';
  static const String pollingStationSearch = 'https://electoralsearch.eci.gov.in/pollingstation';
  static const String complaintRegistration = 'https://eci-citizenservices.eci.nic.in/';
  static const String candidateAffidavit = 'https://affidavit.eci.gov.in/';
  static const String politicalPartyRegistration = 'https://www.eci.gov.in/political-party-registration';
  static const String evmInfo = 'https://eci.gov.in/evm/';
  static const String mccInfo = 'https://eci.gov.in/mcc/';
  static const String electionLaws = 'https://www.eci.gov.in/election-laws';
  static const String eciPublications = 'https://www.eci.gov.in/eci-publication';
  static const String modelChecklist = 'https://www.eci.gov.in/modal-check-list';
  static const String eciImportantInstructions = 'https://www.eci.gov.in/important-instructions/';
  static const String eciJudicialReferences = 'https://eci.gov.in/judicial-reference/';
  static const String vacancyPosition = 'https://ceoelection.maharashtra.gov.in/ceodashboard/';
  static const String resultsPortal = 'https://results.eci.gov.in/';

  // Specific Voter Portal Links
  static const String voterSignup = 'https://voters.eci.gov.in/signup';
  static const String voterLogin = 'https://voters.eci.gov.in/login';
  static const String form6NewVoter = 'https://voters.eci.gov.in/';
  static const String form8Correction = 'https://voters.eci.gov.in/';
  static const String form6BAadhaarLink = 'https://voters.eci.gov.in/';
  static const String trackApplication = 'https://voters.eci.gov.in/';

  // Results Portal specific
  static const String liveResults = 'https://results.eci.gov.in/';
  static const String partyWiseTrends = 'https://results.eci.gov.in/';
  static const String constituencyResults = 'https://results.eci.gov.in/';

  /// Launches the given [url] in the default browser.
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
