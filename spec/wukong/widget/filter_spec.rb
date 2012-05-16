require 'spec_helper'
require 'wukong'

describe :filters, :helpers => true do
  subject{ described_class.new }

  describe Wukong::Widget::All do
    it_behaves_like('a filter processor',
      :good => [true, false, nil, 1, Math::PI, 'The French Revolution', Object.new, Class.new],
      :bad  => [])
  end

  describe Wukong::Widget::None do
    it_behaves_like('a filter processor',
      :good => [],
      :bad  => [true, false, nil, 1, Math::PI, 'The French Revolution', Object.new, Class.new])
  end

  describe Wukong::Widget::RegexpFilter do
    subject{ described_class.new(/^m/) }
    it_behaves_like('a filter processor',
      :good => ['milbarge'],
      :bad  => ['fitzhume'] )
  end

  describe Wukong::Widget::RegexpRejecter do
    subject{ described_class.new(/^m/) }
    it_behaves_like('a filter processor',
      :good => ['fitzhume'],
      :bad  => ['milbarge'] )
  end

  describe Wukong::Widget::ProcFilter do
    let(:raw_proc){ ->(rec){ rec =~ /^m/ } }
    subject{ described_class.new(raw_proc) }
    it_behaves_like('a filter processor',
      :good => ['milbarge'],
      :bad  => ['fitzhume'] )
    context 'is created' do
      it 'with a block' do
        subject = described_class.new{|rec| rec =~ /^m/ }
        subject.should be_select('milbarge')
        subject.should be_reject('fitzhume')
      end
      it 'with an explicit proc' do
        subject = described_class.new( ->(rec){ rec =~ /^m/ } )
        subject.should be_select('milbarge')
        subject.should be_reject('fitzhume')
      end
    end
  end

  describe Wukong::Widget::ProcRejecter do
    let(:raw_proc){ ->(rec){ rec =~ /^m/ } }
    subject{ described_class.new(raw_proc) }
    it_behaves_like('a filter processor',
      :good => ['fitzhume'],
      :bad  => ['milbarge'] )
    context 'is created' do
      it 'with a block' do
        subject = described_class.new{|rec| rec =~ /^m/ }
        subject.should be_select('fitzhume')
        subject.should be_reject('milbarge')
      end
      it 'with an explicit proc' do
        subject = described_class.new( ->(rec){ rec =~ /^m/ } )
        subject.should be_select('fitzhume')
        subject.should be_reject('milbarge')
      end
    end
  end

  describe Wukong::Widget::Limit do
    subject{ described_class.new(3) }
    it_behaves_like 'a processor' do
      before{ mock_next_stage }

      context 'creating' do
        its(:count){ should == 0 }
        its(:max_records){ should == 3 }
      end

      it 'rejects objects if already at the limit' do
        subject = described_class.new(0)
        next_stage.should_not_receive(:process)
        subject.process(mock_record)
      end

      it 'emits objects until at the limit' do
        subject = described_class.new(2); mock_next_stage(subject)
        next_stage.should_receive(:process).with(0)
        next_stage.should_receive(:process).with(1)
        4.times{|n| subject.process(n) }
      end
    end
  end


end
