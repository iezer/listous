include ListsHelper

last_report_day = -1

while 1
  success = true
  date = Time.now
  puts "Starting loop " + date.to_s
  backoff_minutes = 2
  begin
    puts "Polling Twitter for dm and replies to @listous"
    pollTwitter()
  rescue
    puts "error in pollTwitter() sending dm."
    send_dm( "isaacezer", "Error during Listous loop pollTwitter() " + date.to_s )
    success = false
  end
  
  begin
    puts "Polling all users mentions"
    get_all_users_mentions()
  rescue
    puts "Error polling users' mentions"
    send_dm( "isaacezer", "Error during Listous loop get_all_users_mentions() " + date.to_s )
    success = false
  end
  
  if success
    if last_report_day != date.day
      puts ("Success")
      send_dm( "isaacezer", "Listous loop working fine " + date.to_s )
      last_report_day = date.day
    end
  else
    backoff_minutes = 30
  end
  
  sleep backoff_minutes * 60
end
