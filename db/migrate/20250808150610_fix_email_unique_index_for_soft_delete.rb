class FixEmailUniqueIndexForSoftDelete < ActiveRecord::Migration[7.1]
  def up
    # Remove o índice único atual que não considera soft delete
    remove_index :users, :email

    # Adiciona um índice único parcial que considera apenas registros não deletados
    add_index :users, :email, unique: true, where: "deleted_at IS NULL"
  end

  def down
    # Reverte para o índice único original
    remove_index :users, :email
    add_index :users, :email, unique: true
  end
end
