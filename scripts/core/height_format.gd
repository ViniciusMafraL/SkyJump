class_name HeightFormat
extends RefCounted
## Formatação de alturas para exibição: 1254.7 -> "1.254 m".


static func meters(value: float) -> String:
	var digits := str(floori(maxf(value, 0.0)))
	var result := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		result = digits[i] + result
		count += 1
		if count % 3 == 0 and i > 0:
			result = "." + result
	return result + " m"
