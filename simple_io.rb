# frozen_string_literal: true

require 'rexml/document'
require_relative './simple_file'
require 'fileutils'
require 'pg'
require 'active_support'
require 'active_support/core_ext'

# class for read and write xml file
class SimpleIO
  class << self
    def read(id)
      result = pgsession do |t|
        t.prepare('read', "SELECT * FROM #{TABLE} WHERE id = $1")
        t.exec_prepared('read', [id])[0]
      end
      SimpleFile.new(result['id'].to_i, result['title'], result['text'])
    end

    def read_all
      pgsession do |t|
        t.exec("SELECT * FROM #{TABLE}").map { |r| SimpleFile.new(r['id'], r['title'], r['text']) }
      end
    end

    def write(file)
      pgsession do |t|
        t.prepare('write', "INSERT INTO #{TABLE} VALUES ($1,$2,$3)")
        t.exec_prepared('write', [file.id, file.title, file.text])
      end
    end

    def update(file)
      pgsession do |t|
        t.prepare('update', "UPDATE #{TABLE} SET title = $2, text = $3 WHERE id = $1")
        t.exec_prepared('update', [file.id, file.title, file.text])
      end
    end

    def delete(id)
      pgsession do |t|
        t.prepare('delete', "DELETE FROM #{TABLE} WHERE id = $1")
        t.exec_prepared('delete', [id])
      end
    end

    def exist?(id)
      return false unless /^[0-9]+$/.match?(id)

      pgsession do |t|
        t.prepare('exist?', "SELECT EXISTS (SELECT * FROM #{TABLE} WHERE id = $1)")
        t.exec_prepared('exist?', [id])[0]['exists'] == 't'
      end
    end

    def max_id
      pgsession { |t| t.exec("SELECT MAX(id) FROM #{TABLE}")[0]['max'].to_i }
    end

    def pgsession
      conn = PG.connect(CONF)
      conn.transaction { |t| @result = yield t }
      conn.finish
      @result
    end

    def conf
      Hash.from_xml(open('public/conf.xml'))['settings']
    end

    def create_table_if_necessary
      pgsession do |t|
        if t.exec("SELECT EXISTS (SELECT table_name FROM information_schema.columns WHERE table_name = '#{TABLE}')")[0]['exists'] == 'f'
          t.exec("CREATE TABLE #{TABLE} ( id integer, title varchar(5000), text varchar(5000), primary key (id))")
        end
      end
    end
  end

  CONF = conf
  TABLE = 'simple_files'
  create_table_if_necessary
end

