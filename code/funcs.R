library(httr2)
library(jsonlite)

get_cdc_data = function(url_name){
  url_name <- request(url_name) |> 
    req_url_query("$limit" = 10000000) |>
    req_perform() |> 
    resp_body_json(simplifyVector = TRUE)
}




