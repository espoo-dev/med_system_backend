# frozen_string_literal: true

User.create(email: "admin@email.com", password: "password")

procedure_data = [
  "31309054 - Cesariana (feto único ou múltiplo) - porte 5 - 433,00",
  "30213053 - Tireoidectomia total - porte 5 - 433,00",
  "30213045 - Tireoidectomia parcial - porte 4 - 280,00",
  "31403123 - Exploração cirúrgica de nervo (neurólise externa) - porte 3 - 189,00",
  "30911052 - Cateterismo cardíaco D e/ou E com estudo cineangiográfico e de revascularização cirúrgica do
   miocárdio - porte 4 - 280,00".squish,
  "30911141 - Estudo ultrassonográfico intravascular - porte 4 - 280,00",
  "30912105 - Implante de stent coronário com ou sem angioplastia por balão concomitante (1 vaso) - porte 5 - 433,00",
  "30912105 - Implante de stent coronário com ou sem angioplastia por balão concomitante (1 vaso) - porte 5 - 433,00",
  "30912261 - Angioplastia transluminal percutânea de bifurcação e de tronco com implante de stent - porte 5 - 433,00",
  "30912040 - Angioplastia transluminal percutânea por balão (1 vaso) - porte 3 - 189,00",
  "30912318 - Angioplastia transluminal percutânea por balão para tratamento de oclusão coronária crônica com ou
  sem stent - porte 6 - 605,00".squish
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
