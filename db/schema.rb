# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_28_204143) do

  create_table "concepts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer "incarnation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["incarnation_id"], name: "index_games_on_incarnation_id"
  end

  create_table "incarnations", force: :cascade do |t|
    t.integer "concept_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["concept_id"], name: "index_incarnations_on_concept_id"
  end

  create_table "participations", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "initiator", default: false
    t.boolean "accepted", default: false
    t.index ["game_id"], name: "index_participations_on_game_id"
    t.index ["team_id"], name: "index_participations_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lon", precision: 10, scale: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "games", "incarnations"
  add_foreign_key "incarnations", "concepts"
  add_foreign_key "participations", "games"
  add_foreign_key "participations", "teams"
end
