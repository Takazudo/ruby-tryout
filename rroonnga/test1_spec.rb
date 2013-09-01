require 'bundler'
Bundler.require
require './test1.rb'

describe GrManager do
  
  before :all do
    @db_path = '/tmp/groonga/'
    @db_filename = 'groonga.db'
  end

  describe "dbfile handling" do

    it "should complete db setup" do
      res = GrManager.setup @db_path, @db_filename
      (expect res.class).to be Groonga::Database
    end

    it "should remove db" do
      res = GrManager.destroy
      (expect res).to be_true
      (expect (Dir.exist? @db_path)).to be_false
    end

    it "should be able to handle sequential setup/destroy loop" do
      def oneProc
        res = GrManager.setup @db_path, @db_filename
        (expect res.class).to be Groonga::Database
        res = GrManager.destroy
        (expect res).to be_true
      end
      i = 0
      until i == 5 do
        oneProc
        i += 1
      end
    end

  end

  describe GrManager::EntryTable do

    before :each do
      GrManager.setup @db_path, @db_filename
    end
    after :each do
      GrManager.destroy
    end

    it "sholud create table on creation" do
      table = GrManager::EntryTable.new
      (expect table.table_raw.class).to be Groonga::Hash
    end

    it "sholud use existing table on 2nd creation" do
      table1 = GrManager::EntryTable.new
      table2 = GrManager::EntryTable.new
      (expect table1.table_raw).to be table2.table_raw
    end

  end

end
