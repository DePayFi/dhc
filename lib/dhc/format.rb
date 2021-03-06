# frozen_string_literal: true

class DHC::Format

  private

  def no_content_type_header!(options)
    return if (options[:headers].keys & [:'Content-Type', 'Content-Type']).blank?

    raise 'Content-Type header is not allowed for formatted requests!\nSee https://github.com/DePayFi/dhc#formats for more information.'
  end

  def no_accept_header!(options)
    return if (options[:headers].keys & [:Accept, 'Accept']).blank?

    raise 'Accept header is not allowed for formatted requests!\nSee https://github.com/DePayFi/dhc#formats for more information.'
  end
end
