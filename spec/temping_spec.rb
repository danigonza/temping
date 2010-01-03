require File.join(File.dirname(__FILE__), "/spec_helper")

describe Temping do
  include Temping

  describe ".create_model" do    
    it "creates and returns an AR::Base-derived model" do
      post_class = create_model :post
      post_class.ancestors.should include(ActiveRecord::Base)
      post_class.should == Post
      post_class.table_name.should == "posts"
    end

    it "evals all statements passed in through a block" do
      create_model :vote do
        with_columns do |table|
          table.string :voter
        end
        
        validates_presence_of :voter
      end
      
      vote = Vote.new
      vote.should_not be_valid
      
      vote.voter = "Foo Bar"
      vote.should be_valid
    end
    
    it "silently skips initialization if a const is already defined" do
      lambda { 2.times { create_model :dog } }.should_not raise_error
    end
    
    it "returns nil if a const is already defined" do
      create_model :cat
      create_model(:cat).should be_nil
    end
    
    describe ".with_columns" do
      it "creates columns passed in through a block" do
        create_model :comment do 
          with_columns do |table|
            table.integer :count
            table.string :headline
            table.text :body
          end
        end
      
        Comment.columns.map(&:name).should include("count", "headline", "body")
      end
    end
  end
  
  describe "database agnostism" do
    it "supports Sqlite3" do
      ActiveRecord::Base.establish_connection 'temping'
      create_model(:orange).should == Orange

      Orange.connection.class.should == ActiveRecord::ConnectionAdapters::SQLite3Adapter
      Orange.table_name.should == "oranges"
    end

    it "supports MySQL" do
      ActiveRecord::Base.establish_connection 'mysql'
      create_model(:apple).should == Apple

      Apple.connection.class.should == ActiveRecord::ConnectionAdapters::MysqlAdapter
      Apple.table_name.should == "apples"
    end

    it "supports PostgreSQL" do
      ActiveRecord::Base.establish_connection 'postgres'
      create_model(:cherry).should == Cherry

      Cherry.connection.class.should == ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
      Cherry.table_name.should == "cherries"
    end
  end
end