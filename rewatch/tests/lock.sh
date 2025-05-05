source "./utils.sh"
cd ../testrepo

bold "Test: It should lock - when watching"

sleep 1

if rewatch clean &> /dev/null;
then
  success "Repo Cleaned"
else 
  error "Error Cleaning Repo"
  exit 1
fi

exit_watcher() { 
  # Try to find parent process, if not found just kill the process directly
  # PARENT_PROCS=$(pgrep -P $!)
  # if [ -n "$PARENT_PROCS" ]; then
  #   kill $PARENT_PROCS &>/dev/null
  # fi
  # for if it's the node script that runs rewatch also kill the child processes
  CHILD_PROCS=$(pgrep -f rewatch)
  if [ -n "$CHILD_PROCS" ]; then
    kill $! &>/dev/null
    kill $CHILD_PROCS &>/dev/null
  else
    # Last resort: just kill the background process
    kill $!
  fi
}

rewatch watch &>/dev/null &
success "Watcher Started"

sleep 1

if rewatch watch 2>&1 | grep 'Could not start Rewatch:' &> /dev/null; 
then
  success "Lock is correctly set"
  exit_watcher
else 
  error "Not setting lock correctly"
  exit_watcher
  exit 1
fi

sleep 1

touch tmp.txt
rewatch watch &> tmp.txt &
success "Watcher Started"

sleep 1

if cat tmp.txt | grep 'Could not start Rewatch:' &> /dev/null; 
then
  error "Lock not removed correctly"
  exit_watcher
  exit 1
else
  success "Lock removed correctly"
  exit_watcher
fi

rm tmp.txt
