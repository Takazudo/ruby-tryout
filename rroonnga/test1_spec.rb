require 'bundler'
Bundler.require
require './test1.rb'

describe GrManager do
  
  before :all do
    @db_path = '/tmp/groongatest/'
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

    describe "initialization" do

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

    describe "add" do

      it "should add a record" do
        table = GrManager::EntryTable.new
        data1 = { title: 'title1!', body: 'body1!', }
        data2 = { title: 'title2!', body: 'body2!', }
        table.add 1, data1
        (expect table.size).to be 1
        table.add 2, data2
        (expect table.size).to be 2
      end
      
      it "should detect record existing" do
        table = GrManager::EntryTable.new
        data1 = { title: 'title1!', body: 'body1!', }
        table.add 1, data1
        (expect (table.record_exist 1)).to be true
      end

      it "should not allow duplicated id" do
        table = GrManager::EntryTable.new
        data1 = { title: 'title1!', body: 'body1!', }
        data2 = { title: 'title2!', body: 'body2!', }
        table.add 1, data1
        (expect table.size).to be 1
        res = table.add 1, data2
        (expect res).to be false
        (expect table.size).to be 1
      end

    end

    describe "find_by_id" do

      it "should find specified id's record" do
        table = GrManager::EntryTable.new
        data1 = { title: 'title1!', body: 'body1!', }
        data2 = { title: 'title2!', body: 'body2!', }
        table.add 1, data1
        table.add 2, data2
        res1 = (table.find_by_id 1)
        (expect res1[:title]).to eq 'title1!'
        res2 = (table.find_by_id 2)
        (expect res2[:title]).to eq 'title2!'
      end

      it "should return nil when specifed id's record does not exist" do
        table = GrManager::EntryTable.new
        res1 = (table.find_by_id 1)
        (expect res1).to be nil
      end

    end

    describe "update" do

      it "should update specified record" do
        table = GrManager::EntryTable.new
        data_old = { title: 'title!', body: 'body!', }
        data_new = { title: 'updated title!', body: 'updated body!', }
        table.add 1, data_old
        res = table.update_record 1, data_new
        (expect res).to be true
        fetched = (table.find_by_id 1)
        (expect fetched[:title]).to eq 'updated title!'
        (expect fetched[:body]).to eq 'updated body!'
      end

      it "should return false if specified id's record does not exit" do
        table = GrManager::EntryTable.new
        data_new = { title: 'updated title!', body: 'updated body!', }
        res = table.update_record 1, data_new
        (expect res).to be false
      end

    end

    describe "delete" do

      it "should delete the specified id's record" do
        table = GrManager::EntryTable.new
        data1 = { title: 'title1!', body: 'body1!', }
        table.add 1, data1
        res = table.delete 1
        (expect res).to be true
        (expect (table.record_exist 1)).to be false
      end

      it "should return false if the record does not exist." do
        table = GrManager::EntryTable.new
        res = table.delete 1
        (expect res).to be false
      end

    end

  end

end
