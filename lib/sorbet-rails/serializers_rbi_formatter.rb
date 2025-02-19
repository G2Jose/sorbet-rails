# typed: strict

class SorbetRails::SerializersRbiFormatter
  extend T::Sig

  sig { returns(T.class_of(ActiveModel::Serializer)) }
  attr_reader :serializer_class, :available_classes

  sig do
    params(
      serializer_class: T.class_of(ActiveModel::Serializer),
      available_classes: T::Set[String]
    )
      .void
  end
  def initialize(serializer_class, available_classes)
    @parlour = T.let(Parlour::RbiGenerator.new, Parlour::RbiGenerator)
    @serializer_class = T.let(serializer_class, T.class_of(ActiveModel::Serializer))
    @available_classes = T.let(available_classes, T::Set[String])
  end

  sig { returns(String) }
  def generate_rbi
    puts "-- Generate sigs for #{serializer_class.name} --"

    generator = Parlour::RbiGenerator.new(break_params: 3)

    rbi = <<~MESSAGE
      # This is an autogenerated file for dynamic methods in #{serializer_class.name}
      # Please rerun bundle exec rake rails_rbi:models[#{serializer_class.name}] to regenerate.

    MESSAGE

    klass = generator.root.create_class(
      serializer_class.name,
      superclass: serializer_class.superclass.name
    )

    klass.create_method(
      'self.object',
      return_type: serializer_class.name.gsub('Serializer', '')
    )

    klass.create_method(
      'object',
      return_type: serializer_class.name.gsub('Serializer', '')
    )

    rbi += generator.rbi
    rbi
  end
end
