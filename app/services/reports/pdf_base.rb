

module Reports
  class PdfBase
    def initialize(pdf)
      @pdf = pdf
      register_fonts!
      use_default_font!
    end

    private

    attr_reader :pdf

    def register_fonts!
      fonts_dir = Rails.root.join('app/assets/fonts')

      pdf.font_families.update(
        'DejaVu' => {
          normal: fonts_dir.join('DejaVuSans.ttf'),
          bold: fonts_dir.join('DejaVuSans-Bold.ttf')
        }
      )
    end

    def use_default_font!
      pdf.font('DejaVu')
    end
  end
end
