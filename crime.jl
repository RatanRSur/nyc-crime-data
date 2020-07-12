using HTTP
using ExcelReaders
using Pkg

const GET = "GET"

destination_dir = ARGS[1]

for precinct_number in ARGS[2:end]
  filename = join(["cs-en-us-0", precinct_number, "pct.xlsx" ])

  r = HTTP.request(GET, "https://www1.nyc.gov/assets/nypd/downloads/excel/crime_statistics/$filename")
  temp_filename = "/tmp/$filename"
  write(temp_filename, r.body)

  f = openxl(temp_filename)

  function read_cell(begin_cell, end_cell=begin_cell)
    readxl(f, "CompStat_1!$begin_cell:$end_cell")
  end

  dates = replace(replace(replace(read_cell("C9"), "Report Covering the Week  " => ""), "  Through  " => "-"), "/" => ".")

  precinct_destination = "$destination_dir/$precinct_number"
  mkpath(precinct_destination)
  mv(temp_filename, "$precinct_destination/$dates.xlsx")
end

