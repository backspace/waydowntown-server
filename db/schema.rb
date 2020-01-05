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

ActiveRecord::Schema.define(version: 2020_01_05_002650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "incarnation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "begins_at"
    t.datetime "ends_at"
    t.datetime "representing_ends_at"
    t.index ["incarnation_id"], name: "index_games_on_incarnation_id"
  end

  create_table "incarnations", force: :cascade do |t|
    t.string "concept_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "duration"
    t.bigint "location_id"
    t.jsonb "goal"
    t.text "instructions"
    t.jsonb "questions"
    t.text "credit"
    t.string "capabilities", default: [], array: true
    t.decimal "lat"
    t.decimal "lon"
    t.index ["location_id"], name: "index_incarnations_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.geometry "bounds", limit: {:srid=>0, :type=>"multi_polygon"}
    t.bigint "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "capabilities", default: [], array: true
    t.decimal "lat"
    t.decimal "lon"
    t.index ["parent_id"], name: "index_locations_on_parent_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "name"
    t.decimal "lat"
    t.decimal "lon"
    t.bigint "team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_subscribed"
    t.datetime "last_unsubscribed"
    t.string "registration_id"
    t.string "registration_type"
    t.datetime "last_located"
    t.jsonb "capabilities", default: {}
    t.jsonb "device", default: {}
    t.boolean "admin"
    t.string "token"
    t.index ["team_id"], name: "index_members_on_team_id"
  end

  create_table "participations", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "initiator", default: false
    t.string "aasm_state"
    t.boolean "winner"
    t.decimal "score", precision: 10, scale: 6
    t.index ["game_id"], name: "index_participations_on_game_id"
    t.index ["team_id"], name: "index_participations_on_team_id"
  end

  create_table "representations", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "participation_id", null: false
    t.boolean "representing"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "archived"
    t.jsonb "result"
    t.index ["member_id"], name: "index_representations_on_member_id"
    t.index ["participation_id"], name: "index_representations_on_participation_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lon", precision: 10, scale: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "games", "incarnations"
  add_foreign_key "incarnations", "locations"
  add_foreign_key "members", "teams"
  add_foreign_key "participations", "games"
  add_foreign_key "participations", "teams"
  add_foreign_key "representations", "members"
  add_foreign_key "representations", "participations"
end
