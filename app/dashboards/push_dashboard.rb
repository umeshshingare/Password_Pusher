require "administrate/base_dashboard"

class PushDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    deletable_by_viewer: Field::Boolean,
    deleted: Field::Boolean,
    expire_after_days: Field::Number,
    expire_after_views: Field::Number,
    expired: Field::Boolean,
    expired_on: Field::DateTime.with_options(timezone: Settings.timezone),
    files_attachments: Field::HasMany,
    files_blobs: Field::HasMany,
    kind: Field::String,
    note_ciphertext: Field::Text,
    passphrase_ciphertext: Field::Text,
    payload_ciphertext: Field::Text,
    retrieval_step: Field::Boolean,
    url_token: Field::String,
    user: Field::BelongsTo,
    audit_logs: Field::HasMany,
    created_at: Field::DateTime.with_options(timezone: Settings.timezone),
    updated_at: Field::DateTime.with_options(timezone: Settings.timezone)
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    kind
    url_token
    expired
    created_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  # Disabled as Administrate has trouble with ActiveStorage
  # files_attachments
  # files_obs
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    kind
    deletable_by_viewer
    expire_after_days
    expire_after_views
    expired
    expired_on
    note_ciphertext
    passphrase_ciphertext
    payload_ciphertext
    retrieval_step
    url_token
    user
    audit_logs
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  # Disabled as Administrate has trouble with ActiveStorage
  # files_attachments
  # files_blobs
  FORM_ATTRIBUTES = %i[
    kind
    deletable_by_viewer
    expire_after_days
    expire_after_views
    expired
    expired_on
    note_ciphertext
    passphrase_ciphertext
    payload_ciphertext
    retrieval_step
    url_token
    user
    audit_logs
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how pushes are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(push)
  #   "Push ##{push.id}"
  # end
  def display_resource(push)
    "Push-#{push.url_token}"
  end
end
