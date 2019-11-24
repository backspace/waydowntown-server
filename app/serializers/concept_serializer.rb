class ConceptSerializer
  include FastJsonapi::ObjectSerializer
  set_type :concept
  attributes :name
end
