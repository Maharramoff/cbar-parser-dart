import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:convert' show utf8, JsonEncoder;

Future<void> main() async {
  final currenciesAPI = "https://www.cbar.az/currencies/07.06.2020.xml";
  final response = await http.get(currenciesAPI);
  final decodedBody = utf8.decode(response.bodyBytes);
  final raw = xml.parse(decodedBody);
  final elements = raw.findAllElements("Valute");

  const ignoredCodes = ["XPD", "XPT", "XAG", "XAU", "SDR"];
  Map<String, Map> currencies = {};
  currencies["AZN"] = {
    "nominal": 1,
    "name": "1 Azərbaycan manatı",
    "value": 1.00
  };
  for (var el in elements) {
    String code = el.getAttribute("Code");
    if (ignoredCodes.contains(code)) continue;
    var nominal = int.tryParse(el.findElements("Nominal").first.text);
    String name = el.findElements("Name").first.text;
    double value = double.tryParse(el.findElements("Value").first.text);
    currencies[code] = {"nominal": nominal, "name": name, "value": value};
  }

  print(new JsonEncoder.withIndent("\t").convert(currencies));
}
