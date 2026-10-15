#!/bin/bash
# Part 8 self-check. Run from your Part8 folder:  bash check8.sh
V=${V:-0}
D="${1:-Part8}"
if [ -d "$D" ]; then cd "$D"; elif ls *.cpp >/dev/null 2>&1; then :; else echo "Can't find your Part 8 files. Use cd to go into your Part 8 folder, then run this again."; exit 1; fi

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
PASS=0; TOTAL=0; HANG=""; CRASH=""
good() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); echo "  PASS  $1"; }
bad()  { TOTAL=$((TOTAL+1)); echo "  FAIL  $1"; [ -n "$2" ] && echo "        Hint: $2"; }
finish() { echo; echo "$PASS of $TOTAL checks passed."; echo "These checks are a guide, not your grade. Passing all of them does not guarantee full credit."; exit 0; }

CPPS=$(find . -name '*.cpp' -not -path './.git/*' | sort)
HDRS=$(find . -name '*.h' -not -path './.git/*' | sort)
INC=$(for h in $HDRS; do dirname "$h"; done | sort -u | sed 's/^/-I/' | tr '\n' ' ')

echo "Part 8 self-check"
if [ "$V" = 1 ]; then
  echo "######## $(basename "$(dirname "$PWD")") / $(basename "$PWD") ########"
  echo; echo "== FILES =="; find . -type f -not -path './.git/*' | sort
  echo; echo "== INPUT LINES (getline, cin >>, cin.ignore) =="; grep -nH -E 'getline|cin *>>|cin\.ignore' $CPPS
  echo; echo "== LOOP AND SEARCH LINES (while, for, SIZE, 20) =="; grep -nH -E '\b(while|for)\b' $CPPS | grep -v 'choice'
fi

echo; echo "Build"
OBJS=""; BUILD_OK=1; i=0
for f in $CPPS; do
  i=$((i+1)); o="$T/o$i.o"
  g++ -Wall -Wextra $INC -c "$f" -o "$o" 2>>"$T/build.log" || BUILD_OK=0
  OBJS="$OBJS $o"
done
if [ "$BUILD_OK" = 1 ]; then g++ $OBJS -o "$T/prog" 2>>"$T/build.log" || BUILD_OK=0; fi
if [ "$BUILD_OK" = 1 ]; then good "Program builds ($(grep -c 'warning' "$T/build.log") warnings)"; else
  bad "Program does not build" "Fix the first error below, then run this again."
  grep -E 'error|undefined|multiple definition' "$T/build.log" | head -10
  tip() { grep -qE "$1" "$T/build.log" && echo "        Tip: $2"; }
  tip "'string' (was not declared|does not name a type|has not been declared|is not a member of)" "Add #include <string> and using namespace std; to the file named in the error."
  tip "'(cout|cin|endl|getline)' (was not declared|is not a member)" "Add #include <iostream> (and #include <string> for getline) and using namespace std; to the file named in the error."
  tip "'(bookTitle|isbn|author|publisher|dateAdded|qtyOnHand|wholesale|retail)' (was not declared|is not a member)" "A function in this file uses a global array defined in another file. Add an extern declaration for it, for example: extern string bookTitle[20];"
  tip "undefined reference to .(bookTitle|isbn|author|publisher|dateAdded|qtyOnHand|wholesale|retail)" "An extern declaration has no matching definition. Define each array in exactly one .cpp file."
  tip "multiple definition of" "A global array or function is defined more than once. Define each array in a single .cpp file, and use extern declarations everywhere else."
  finish
fi

SAN="-g -fsanitize=address,undefined -fno-omit-frame-pointer"
printf '%s\n' 'int main() { return 0; }' > "$T/san.cpp"
g++ $SAN "$T/san.cpp" -o "$T/san" 2>/dev/null && [ "$("$T/san"; echo $?)" = 0 ] || SAN=""
SOBJS=""; i=0
for f in $CPPS; do
  i=$((i+1)); o="$T/s$i.o"
  g++ $SAN $INC -c "$f" -o "$o" 2>/dev/null
  if nm --defined-only "$o" 2>/dev/null | grep -qE ' T main$'; then objcopy --redefine-sym main=student_main "$o"; fi
  SOBJS="$SOBJS $o"
done

cat > "$T/drv.cpp" <<'DRV'
#include <iostream>
#include <string>
using namespace std;
extern string bookTitle[20];
extern string isbn[20];
extern string author[20];
extern string publisher[20];
extern string dateAdded[20];
extern int qtyOnHand[20];
extern double wholesale[20];
extern double retail[20];
void addBook();
void lookUpBook();
void editBook();
void deleteBook();
struct Rec { string t, i, a, p, d; int q; double w, r; };
static Rec snap[20];
static void put(int n, string t, string i, string a, string p, string d, int q, double w, double r)
{ bookTitle[n] = t; isbn[n] = i; author[n] = a; publisher[n] = p; dateAdded[n] = d; qtyOnHand[n] = q; wholesale[n] = w; retail[n] = r; }
static void clearAll() { for (int n = 0; n < 20; n++) put(n, "", "", "", "", "", 0, 0, 0); }
static void seed3()
{
  clearAll();
  put(0, "History of Scotland", "1-111-11111-1", "Author One", "Press One", "01-01-2020", 5, 8.25, 14.99);
  put(1, "Robert the Bruce", "2-222-22222-2", "Haynes Timothy", "Historical Press", "02-02-2021", 7, 10.75, 21.5);
  put(2, "Gaelic Basics", "3-333-33333-3", "Mary MacLeod", "Celtic Books", "03-03-2022", 9, 6.25, 12.99);
}
static void take()
{ for (int n = 0; n < 20; n++) snap[n] = Rec{bookTitle[n], isbn[n], author[n], publisher[n], dateAdded[n], qtyOnHand[n], wholesale[n], retail[n]}; }
static void report()
{
  cout.flags(ios_base::dec | ios_base::skipws); cout.precision(6); cout.width(0);
  cout << "\n@@REPORT@@\n";
  for (int n = 0; n < 20; n++)
  {
    string d;
    if (bookTitle[n] != snap[n].t) d += "title,";
    if (isbn[n] != snap[n].i) d += "isbn,";
    if (author[n] != snap[n].a) d += "author,";
    if (publisher[n] != snap[n].p) d += "publisher,";
    if (dateAdded[n] != snap[n].d) d += "date,";
    if (qtyOnHand[n] != snap[n].q) d += "qty,";
    if (wholesale[n] != snap[n].w) d += "wholesale,";
    if (retail[n] != snap[n].r) d += "retail,";
    if (!d.empty())
    {
      cout << "CHG|" << n << "|" << bookTitle[n] << "|" << isbn[n] << "|" << author[n] << "|" << publisher[n] << "|" << dateAdded[n] << "|" << qtyOnHand[n] << "|" << wholesale[n] << "|" << retail[n] << "\n";
      cout << "DIFF|" << n << "|" << d << "\n";
    }
  }
  cout << "DONE\n";
}
int main(int argc, char** argv)
{
  string s = argc > 1 ? argv[1] : "";
  int menu = 0;
  if (s == "add1") { clearAll(); take(); cin >> menu; addBook(); }
  else if (s == "add2") { clearAll(); put(0, "Existing Book", "9-999-99999-9", "Old Author", "Old Press", "05-05-2019", 3, 5.5, 9.5); take(); cin >> menu; addBook(); }
  else if (s == "addreuse") { seed3(); bookTitle[1] = ""; isbn[1] = ""; take(); cin >> menu; addBook(); }
  else if (s == "addfull") { clearAll(); for (int n = 0; n < 20; n++) put(n, "Book " + to_string(n + 1), "I-" + to_string(n + 1), "A", "P", "01-01-2020", 1, 1.5, 2.5); take(); cin >> menu; addBook(); }
  else if (s == "lookup") { seed3(); take(); cin >> menu; lookUpBook(); }
  else if (s == "edit") { seed3(); take(); cin >> menu; editBook(); }
  else if (s == "delete") { seed3(); take(); cin >> menu; deleteBook(); }
  else if (s == "deletelookup") { seed3(); take(); cin >> menu; deleteBook(); cout << "\n@@LOOKUP@@\n"; cin >> menu; lookUpBook(); }
  report();
  return 0;
}
DRV
if ! g++ $SAN -c "$T/drv.cpp" -o "$T/drv.o" 2>"$T/drv.log"; then bad "The test program could not be built" "This is a problem with the check itself. Tell your teacher."; head -5 "$T/drv.log"; finish; fi
if ! g++ $SAN "$T/drv.o" $SOBJS -o "$T/drv" 2>"$T/link.log"; then
  bad "The tests could not be linked to your code" "The tests need the eight global arrays from Part 7 with the exact names and types (for example string bookTitle[20] and int qtyOnHand[20]), and addBook, lookUpBook, editBook, and deleteBook as functions with no parameters."
  grep -E 'undefined reference|multiple definition' "$T/link.log" | head -6
  finish
fi

run_s() { # driver-scenario input
  printf "$2" | ASAN_OPTIONS=detect_leaks=0 timeout 5 "$T/drv" "$1" > "$T/out.txt" 2>&1; CODE=$?
  OUT=$(head -c 30000 "$T/out.txt")
  STU=$(sed '/@@REPORT@@/,$d' <<<"$OUT")
  if [ "$CODE" = 124 ]; then HANG="$HANG $1"; elif [ "$CODE" != 0 ]; then CRASH="$CRASH $1"; fi
  if grep -qE 'AddressSanitizer|runtime error' <<<"$OUT"; then CRASH="$CRASH $1"; fi
  if [ "$V" = 1 ] && [ "${3:-}" != quiet ]; then echo; echo "-- scenario $1, input: $2 (exit $CODE) --"; head -c 900 <<<"$OUT" | head -14; fi
}
chg()   { grep "^CHG|$1|" <<<"$OUT" | head -1; }
diffs() { grep "^DIFF|$1|" <<<"$OUT" | head -1 | cut -d'|' -f3; }
nchg()  { grep -c '^DIFF|' <<<"$OUT"; }
fld()   { # line fieldname
  local idx; case $2 in title) idx=3;; isbn) idx=4;; author) idx=5;; publisher) idx=6;; date) idx=7;; qty) idx=8;; wholesale) idx=9;; retail) idx=10;; esac
  cut -d'|' -f$idx <<<"$1"
}
fieldcmp() { # want got -> names of differing fields
  local names=(CHG slot title isbn author publisher date qty wholesale retail) W G k out=""
  IFS='|' read -r -a W <<<"$1"; IFS='|' read -r -a G <<<"$2"
  for k in 2 3 4 5 6 7 8 9; do [ "${W[$k]}" = "${G[$k]}" ] || out="$out ${names[$k]}"; done
  echo "$out"
}
has() { grep -qF "$1" <<<"$2"; }
notmsg() { grep -qiE "not |no |n't|cannot|couldn|invalid" <<<"$1"; }

NEWREC='Title One\n1-111-11111-1\nAuthor One\nPublisher One\n01-02-2020\n5\n10.50\n19.99\n'
WANT='CHG|0|Title One|1-111-11111-1|Author One|Publisher One|01-02-2020|5|10.5|19.99'

echo; echo "addBook"
run_s add1 "2\n$NEWREC"
got=$(chg 0)
if [ "$(nchg)" = 1 ] && [ "$got" = "$WANT" ]; then good "addBook stores all eight fields in the same slot"
else d=$(fieldcmp "$WANT" "$got"); bad "addBook did not store all eight fields correctly${got:+ (wrong or missing:$d)}" "Prompt for title, ISBN, author, publisher, date added, quantity, wholesale cost, and retail price, in that order, and store each in its array at the same subscript. Use getline for text, and clear the leftover newline first."; fi
run_s add2 "2\n$NEWREC"
WANT1="${WANT/CHG|0|/CHG|1|}"
if [ "$(nchg)" = 1 ] && [ "$(chg 1)" = "$WANT1" ]; then good "A second book goes into the next empty slot"; else bad "A second book did not go into the next empty slot" "Search bookTitle for the first element that is an empty string, and store the new book there without changing the other books."; fi
run_s addreuse "2\n$NEWREC"
if [ "$(nchg)" = 1 ] && [ "$(chg 1)" = "$WANT1" ]; then good "An emptied (deleted) slot is reused"; else bad "An emptied slot was not reused" "A deleted book has an empty title, so addBook should find that slot first and overwrite all eight fields."; fi
run_s addfull "2\nShould Not Store\nx\nx\nx\nx\n1\n1\n1\n"
if [ "$CODE" = 0 ] && [ "$(nchg)" = 0 ] && [ -n "$(tr -d '[:space:]' <<<"$STU")" ] && ! grep -qE ':[[:space:]]*$' <<<"$STU"; then good "A full inventory is reported before any prompting, and nothing is overwritten"
else bad "A full inventory is not handled correctly" "Search for an empty slot first. If there is none, show a message that no more books can be added and return, without asking for any data and without changing any book."; fi

echo; echo "lookUpBook"
run_s lookup "2\nRobert the Bruce\n"
ok=1; for v in "2-222-22222-2" "Robert the Bruce" "Haynes Timothy" "Historical Press" "02-02-2021"; do has "$v" "$STU" || ok=0; done
grep -qE '(^|[^0-9.])7([^0-9]|$)' <<<"$STU" || ok=0; grep -qE '10\.75' <<<"$STU" || ok=0; grep -qE '21\.5' <<<"$STU" || ok=0
has "1-111-11111-1" "$STU" && ok=0; has "3-333-33333-3" "$STU" && ok=0
if [ "$ok" = 1 ]; then good "lookUpBook finds a title with spaces and shows all eight values for that book"; else bad "lookUpBook did not show the right book" "Read the title with getline (and clear the leftover newline first), search bookTitle for an exact match, and call bookInfo with the eight values at that subscript."; fi
run_s lookup "2\nNo Such Book\n"
if ! has "ISBN" "$STU" && notmsg "$STU"; then good "lookUpBook says when a title is not in inventory"; else bad "lookUpBook did not handle a title that is not in inventory" "If no title matches, show a message that the book is not in inventory and return. Do not show the Book Information screen."; fi

echo; echo "editBook"
run_s edit "2\nRobert the Bruce\n9\n"
printf '%s\n' "$STU" > "$T/base_edit"
if [ "$CODE" = 0 ] && [ "$(nchg)" = 0 ] && has "2-222-22222-2" "$STU" && has "Haynes Timothy" "$STU" && has "Historical Press" "$STU"; then good "editBook shows the book's details first, and choosing 9 exits"; else bad "editBook did not show the details or did not exit on 9" "After the title is found, call bookInfo to display the book, then show the edit menu. Menu choice 9 should end the function."; fi
run_s edit "2\nNo Such Book\n"
if [ "$(nchg)" = 0 ] && notmsg "$STU"; then good "editBook says when a title is not in inventory"; else bad "editBook did not handle a title that is not in inventory" "If no title matches, show a message that the book is not in inventory and return."; fi
MAPOK=1; MAPTXT=""; declare -A KEY; declare -A SEEN
for k in 1 2 3 4 5 6 7 8; do
  run_s edit "2\nRobert the Bruce\n$k\n77\n9\n" quiet
  df=$(diffs 1); df=${df%,}
  if [ "$(nchg)" = 1 ] && [ -n "$df" ] && [[ "$df" != *,* ]] && [ "$(fld "$(chg 1)" "$df")" = 77 ]; then KEY[$df]=$k; SEEN[$df]=1; MAPTXT="$MAPTXT $k=$df"
  else MAPOK=0; MAPTXT="$MAPTXT $k=?(${df:-nothing changed})"; fi
done
[ "$V" = 1 ] && echo && echo "edit menu map (choice=field):$MAPTXT"
if [ "$MAPOK" = 1 ] && [ "${#SEEN[@]}" = 8 ]; then good "Each of menu choices 1-8 changes exactly one field, and together they cover all eight"; else bad "The edit menu does not change the eight fields correctly (choice=field:$MAPTXT)" "Each choice from 1 to 8 should ask for a new value and save it into one array at the book's subscript. Together they cover ISBN, title, author, publisher, date added, quantity, wholesale cost, and retail price."; fi
if [ "$MAPOK" = 1 ] && [ "${#SEEN[@]}" = 8 ]; then
  badt=""
  for f in title author publisher date; do
    run_s edit "2\nRobert the Bruce\n${KEY[$f]}\nNew Words Here\n9\n" quiet
    [ "$(fld "$(chg 1)" "$f")" = "New Words Here" ] || badt="$badt $f"
  done
  if [ -z "$badt" ]; then good "Text fields keep values with spaces"; else bad "A new value with spaces was cut short or lost for:$badt" "Use getline for text fields, and clear the leftover newline with cin.ignore() before it."; fi
  run_s edit "2\nRobert the Bruce\n${KEY[author]}\nAuthor X\n${KEY[publisher]}\nPublisher Y\n${KEY[qty]}\n42\n9\n"
  if [ "$CODE" = 0 ] && [ "$(fld "$(chg 1)" author)" = "Author X" ] && [ "$(fld "$(chg 1)" publisher)" = "Publisher Y" ] && [ "$(fld "$(chg 1)" qty)" = 42 ]; then good "Several fields can be changed in one session"; else bad "Changing several fields in one session did not work" "The edit menu should repeat after each change until the user chooses 9."; fi
else
  bad "Text values with spaces could not be tested" "Fix the edit menu choices first."
  bad "Changing several fields in one session could not be tested" "Fix the edit menu choices first."
fi
run_s edit "2\nRobert the Bruce\n10\n9\n"
added=$(grep -vxFf "$T/base_edit" <<<"$STU" | tr -d '[:space:]')
if [ "$CODE" = 0 ] && [ -n "$added" ]; then good "A bad menu number shows a message and asks again"; else bad "A bad menu number was not handled" "If the choice is not from 1 to 9, show a message and ask again."; fi

echo; echo "deleteBook"
run_s delete "2\nRobert the Bruce\nn\n"
if [ "$CODE" = 0 ] && has "2-222-22222-2" "$STU" && has "Haynes Timothy" "$STU" && grep -qiE 'sure|confirm|y/n|\(y|yes' <<<"$STU"; then good "deleteBook shows the book's details and asks for confirmation"; else bad "deleteBook did not show the details and ask for confirmation" "After the title is found, call bookInfo, then ask the user to confirm with Y or N before deleting anything."; fi
if [ "$(nchg)" = 0 ]; then good "Answering N keeps the book"; else bad "Answering N changed the inventory" "Only delete the book when the user confirms."; fi
run_s delete "2\nRobert the Bruce\nY\n"
if [ "$(nchg)" = 1 ] && [ "$(fld "$(chg 1)" title)" = "" ] && [ "$(fld "$(chg 1)" isbn)" = "" ]; then good "Answering Y sets the title and ISBN to empty strings, and no other book changes"; else bad "Answering Y did not clear exactly that book's title and ISBN" "When the user confirms, set bookTitle and isbn at that subscript to the empty string. Do not change the other books."; fi
if [ "$V" = 1 ]; then run_s delete "2\nRobert the Bruce\ny\n"; echo "lowercase y: diffs for slot 1 = $(diffs 1)"; fi
run_s delete "2\nNo Such Book\n"
if [ "$(nchg)" = 0 ] && notmsg "$STU" && ! has "Are you sure" "$STU"; then good "deleteBook says when a title is not in inventory"; else bad "deleteBook did not handle a title that is not in inventory" "If no title matches, show a message that the book is not in inventory and return."; fi
run_s deletelookup "2\nRobert the Bruce\nY\n2\nRobert the Bruce\n"
AFTER=$(sed '1,/@@LOOKUP@@/d' <<<"$STU")
if ! has "2-222-22222-2" "$AFTER" && notmsg "$AFTER"; then good "A deleted book can no longer be found"; else bad "A deleted book can still be found" "Deleting must clear the title (and ISBN), so a later search for that title finds nothing."; fi

echo; echo "Safe processing"
if [ "$V" = 1 ]; then run_s lookup "2\n\n"; fi
OFF=$(grep -nH -E '\b(while|for)\b' $CPPS | perl -ne 'print if /<=\s*(SIZE|20)\b(?!\s*-\s*1)|<\s*21\b/')
[ "$V" = 1 ] && [ -n "$OFF" ] && echo "loop lines that may run past slot 19:" && echo "$OFF"
if [ -z "$OFF" ]; then good "Every loop over the arrays stops at slot 19"; else bad "A loop may run past the last slot (slot 19)" "The arrays have 20 slots, numbered 0 to 19. Use index < 20 (or index < SIZE) and not index <= SIZE. Check: $(head -1 <<<"$OFF" | cut -d: -f1-2)"; fi
HANG=$(echo $HANG | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' '); CRASH=$(echo $CRASH | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ')
if [ -z "$HANG" ]; then good "No test hung or waited for input forever"; else bad "These tests hung:$HANG" "A prompt may be waiting for input that never comes, or a loop never ends. Check getline and cin.ignore() use, and your loops."; fi
if [ -z "$CRASH" ]; then good "No test crashed or used an array slot outside 0 to 19"; else bad "A crash or out-of-range access happened in:$CRASH" "Make sure every loop stays inside the arrays (slots 0 to 19) and every not-found and full-inventory case returns cleanly."; fi
[ -z "$SAN" ] && echo "  (The memory-safety tools were not available here, so out-of-range access could not be detected.)"
finish