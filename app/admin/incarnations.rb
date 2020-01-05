ActiveAdmin.register Incarnation do
  permit_params :concept_id, :duration, :location_id, :goal, :instructions, :questions, :credit, :capabilities_raw, :lat, :lon

  json_editor

  form do |f|
    f.semantic_errors
    f.inputs except: [:capabilities]
    f.inputs do
      # Adapted from https://stackoverflow.com/a/27607475/760389
      f.input :capabilities_raw, as: :text
    end
    f.actions
  end
end
