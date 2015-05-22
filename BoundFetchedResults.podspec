Pod::Spec.new do |s|
  s.name         = "BoundFetchedResults"
  s.version      = "0.1.1"
  s.summary      = "BoundFetchedResults takes the work out of binding CoreData to your UITableView."
  s.homepage     = "https://github.com/ConventionalC/BoundFetchedResults"
  s.license      = "MIT"
  s.author       = { "Peter DeWeese" => "peter@dewee.se" }
  s.platform     = :ios, "6.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/ConventionalC/BoundFetchedResults.git", :tag => s.version }
  s.source_files = "BoundFetchedResults/*.{h,m}"
  s.public_header_files = "BoundFetchedResults/*.h"
  s.frameworks   = 'Foundation'
end
