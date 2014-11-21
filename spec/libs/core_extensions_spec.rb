# -*- encoding : utf-8 -*-
require_relative '../spec_helper'

describe 'Hash' do
  let(:hash) { {1 => 2, 2 => {3 => {4 => 5}}} }
  let(:up_hash) { {:aaa=>"AABBCC", :bbb=>"DDDEEEFFF"} }

  it 'should support one level traversal' do
    hash.traverse(1).should == 2
  end

  it 'should support one level traversal' do
    hash.traverse(2, 3).should == {4 => 5}
  end
  
  it 'should support one level traversal' do
    hash.traverse(2, 3, 4).should == 5
  end

  it 'should support one level traversal' do
    hash.traverse(2).should == {3 => {4 => 5}}
  end  

  it 'should support traversal with no match' do
    hash.traverse(2, 3, 6).should be_nil
  end  

  it 'should convert to downcase' do
    up_hash.to_downcase.should == {:aaa=>"aabbcc", :bbb=>"dddeeefff"}
  end
 
end


