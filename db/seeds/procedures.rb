# frozen_string_literal: true

procedure_data = [
  "31309054 - Cesariana (feto único ou múltiplo) - porte anestésico 5 - 433,00",
  "30213053 - Tireoidectomia total - porte anestésico 5 - 433,00",
  "30213045 - Tireoidectomia parcial - porte anestésico 4 - 280,00",
  "31403123 - Exploração cirúrgica de nervo (neurólise externa) - porte anestésico 3 - 189,00",
  "30911052 - Cateterismo cardíaco D e/ou E com estudo cineangiográfico e de revascularização cirúrgica do miocárdio -
   porte anestésico 4 - 280,00".squish,
  "30911141 - Estudo ultrassonográfico intravascular - porte anestésico 4 - 280,00",
  "30912105 - Implante de stent coronário com ou sem angioplastia por balão concomitante (1 vaso) - porte
   anestésico 5 - 433,00".squish,
  "30912261 - Angioplastia transluminal percutânea de bifurcação e de tronco com implante de stent - porte
   anestésico 5 - 433,00".squish,
  "30912040 - Angioplastia transluminal percutânea por balão (1 vaso) - porte anestésico 3 - 189,00",
  "30912318 - Angioplastia transluminal percutânea por balão para tratamento de oclusão coronária crônica com ou sem
   stent - porte anestésico 6 - 605,00".squish,
  "31003079 - Apendicectomía - porte anestésico 3 - 189,00",
  "31003583 - Apendicectomia por videolaparoscopia - porte anestésico 5 - 433,00",
  "31005101 - Colecistectomia com colangiografia - porte anestésico 5 - 433,00",
  "31005470 - Colecistectomia com colangiografia por videolaparoscopia - porte anestésico 6 - 605,00",
  "31005110 - Colecistectomia com fístula biliodigestiva - porte anestésico 5 - 433,00",
  "31005489 - Colecistectomia com fístula biliodigestiva por videolaparoscopia - porte anestésico 6 - 605,00",
  "31005128 - Colecistectomia sem colangiografia - porte anestésico 4 - 280,00",
  "31005497 - Colecistectomia sem colangiografia por videolaparoscopia - porte anestésico 5 - 433,00",
  "31005446 - Coledocotomia ou coledocostomia com colecistectomia - porte anestésico 5 - 433,00",
  "31004300 - Tratamento cirúrgico de retocele (colpoperineoplastia posteior) - porte anestésico 2 - 128,00",
  "31302068 - Colporrafia ou colpoperineoplastia incluindo ressecção de septo ou ressutura de parede vaginal - porte
   anestésico 3 - 189,00".squish,
  "31309062 - Curetagem pós-abortamento - porte anestésico 2 - 128,00",
  "31303056 - Curetagem ginecológica semiótica e/ou terapêutica com ou sem dilatação de colo uterino - porte
   anestésico 1 - 88,00".squish,
  "31003370 - Fechamento de colostomia ou enterostomia - porte anestésico 3 - 189,00"
]

def parse_procedure_string(procedure_string)
  code, name, description, amount = procedure_string.split(" - ")
  amount_cents = amount.delete(",").to_i
  { code: code, name: name, description: description, amount_cents: amount_cents }
end

procedure_data.each do |procedure_string|
  attributes = parse_procedure_string(procedure_string)
  Procedure.create!(attributes)
end
