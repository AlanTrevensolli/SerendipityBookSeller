#!/bin/bash
# Part 9 self-check. Run from your Part9 folder:  bash check9.sh
V=${V:-0}
D="${1:-Part9}"
if [ -d "$D" ]; then cd "$D"; elif ls *.cpp >/dev/null 2>&1; then :; else echo "Can't find your Part 9 files. Use cd to go into your Part 9 folder, then run this again."; exit 1; fi

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
PASS=0; TOTAL=0; HANG=""; CRASH=""
declare -A RES
good() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); RES[$1]=1; echo "  PASS  $2"; }
bad()  { TOTAL=$((TOTAL+1)); RES[$1]=0; echo "  FAIL  $2"; [ -n "$3" ] && echo "        Hint: $3"; }
chk()  { local id="$1" label="$2" hint="$3"; shift 3; if "$@"; then good "$id" "$label"; else bad "$id" "$label" "$hint"; fi; }
finish() { echo; echo "$PASS of $TOTAL checks passed."; echo "These checks are a guide, not your grade. Passing all of them does not guarantee full credit."; exit 0; }

CPPS=$(find . -name '*.cpp' -not -path './.git/*' | sort)
HDRS=$(find . -name '*.h' -not -path './.git/*' | sort)
INC=$(for h in $HDRS; do dirname "$h"; done | sort -u | sed 's/^/-I/' | tr '\n' ' ')

echo "Part 9 self-check"
if [ "$V" = 1 ]; then
  echo "######## $(basename "$(dirname "$PWD")") / $(basename "$PWD") ########"
  echo; echo "== FILES =="; find . -type f -not -path './.git/*' | sort
fi

echo; echo "Build"
OBJS=""; BUILD_OK=1; i=0
for f in $CPPS; do
  i=$((i+1)); o="$T/o$i.o"
  g++ -Wall -Wextra $INC -c "$f" -o "$o" 2>>"$T/build.log" || BUILD_OK=0
  OBJS="$OBJS $o"
done
if [ "$BUILD_OK" = 1 ]; then g++ $OBJS -o "$T/prog" 2>>"$T/build.log" || BUILD_OK=0; fi
if [ "$BUILD_OK" = 1 ]; then good B "Program builds ($(grep -c 'warning' "$T/build.log") warnings)"; else
  bad B "Program does not build" "Fix the first error below, then run this again."
  grep -E 'error|undefined|multiple definition' "$T/build.log" | head -10
  tip() { grep -qE "$1" "$T/build.log" && echo "        Tip: $2"; }
  tip "'SIZE' (was not declared|has not been declared)" "Define const int SIZE = 20; in the file named in the error, or in a header that file includes."
  tip "'(bookTitle|isbn|author|publisher|dateAdded|qtyOnHand|wholesale|retail)' (was not declared|is not a member)" "This file uses a global array defined in another file. Add an extern declaration for it, for example: extern string bookTitle[SIZE];"
  tip "undefined reference to .(bookTitle|isbn|author|publisher|dateAdded|qtyOnHand|wholesale|retail)" "An extern declaration has no matching definition. Define each array in exactly one .cpp file."
  tip "multiple definition of" "A global array or function is defined more than once. Define each array in a single .cpp file, and use extern declarations everywhere else."
  tip "'string' (was not declared|does not name a type)" "Add #include <string> and using namespace std; to the file named in the error."
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
void cashier();
void repListing();
void repWholesale();
void repRetail();
void repQty();
void repCost();
void repAge();
static void put(int n, string t, string i, string a, string p, string d, int q, double w, double r)
{ bookTitle[n] = t; isbn[n] = i; author[n] = a; publisher[n] = p; dateAdded[n] = d; qtyOnHand[n] = q; wholesale[n] = w; retail[n] = r; }
int main(int argc, char** argv)
{
  string s = argc > 1 ? argv[1] : "";
  for (int n = 0; n < 20; n++) put(n, "", "", "", "", "", 0, 0, 0);
  put(0, "Alpha",   "1-111-11111-1", "AuthorA", "PressA", "03-15-2021",  5, 10.00, 20.00);
  put(1, "Bravo",   "2-222-22222-2", "AuthorB", "PressB", "01-10-2022", 12,  7.50, 15.00);
  put(2, "Charlie", "3-333-33333-3", "AuthorC", "PressC", "11-05-2019",  1, 22.00, 40.00);
  put(3, "Delta",   "4-444-44444-4", "AuthorD", "PressD", "07-20-2020",  8,  3.00,  6.00);
  put(4, "", "", "", "", "12-31-2023", 99, 99.00, 199.00);
  put(5, "Echo",    "5-555-55555-5", "AuthorE", "PressE", "03-02-2021",  3, 12.00, 25.00);
  put(6, "Foxtrot", "6-666-66666-6", "AuthorF", "PressF", "12-31-2019",  2,  5.50, 11.00);
  if (s == "cash21") qtyOnHand[0] = 100;
  int menu = 0;
  cin >> menu;
  if (s.compare(0, 4, "cash") == 0) cashier();
  else if (s == "listing") repListing();
  else if (s == "wholesale") repWholesale();
  else if (s == "retail") repRetail();
  else if (s == "qty") repQty();
  else if (s == "cost") repCost();
  else if (s == "age") repAge();
  cout.flags(ios_base::dec | ios_base::skipws); cout.precision(6); cout.width(0);
  cout << "\n@@REPORT@@\n";
  for (int n = 0; n < 20; n++)
    cout << "ARR|" << n << "|" << bookTitle[n] << "|" << isbn[n] << "|" << dateAdded[n] << "|" << qtyOnHand[n] << "|" << wholesale[n] << "|" << retail[n] << "\n";
  cout << "DONE\n";
  return 0;
}
DRV
if ! g++ $SAN -c "$T/drv.cpp" -o "$T/drv.o" 2>"$T/drv.log"; then bad X "The test program could not be built" "This is a problem with the check itself. Tell your teacher."; head -5 "$T/drv.log"; finish; fi
if ! g++ $SAN "$T/drv.o" $SOBJS -o "$T/drv" 2>"$T/link.log"; then
  bad X "The tests could not be linked to your code" "The tests need the eight global arrays from Part 7 with the exact names and types (for example string bookTitle[20] and int qtyOnHand[20]), and cashier, repListing, repWholesale, repRetail, repQty, repCost, and repAge as functions with no parameters."
  grep -E 'undefined reference|multiple definition' "$T/link.log" | head -6
  finish
fi

NAME=""; INP=""
run_s() { # scenario input [quiet]
  NAME="$1"; INP="$2"
  printf "$2" | ASAN_OPTIONS=detect_leaks=0 timeout 3 "$T/drv" "$1" 2>&1 | head -c 60000 > "$T/out.txt"; CODE=${PIPESTATUS[1]}
  OUT=$(head -c 60000 "$T/out.txt")
  STU=$(sed '/@@REPORT@@/,$d' <<<"$OUT")
  ARR=$(sed -n '/@@REPORT@@/,$p' <<<"$OUT" | grep '^ARR|')
  if [ "$CODE" = 124 ] || [ "$CODE" = 141 ]; then HANG="$HANG $1"; elif [ "$CODE" != 0 ]; then CRASH="$CRASH $1"; fi
  if grep -qE 'AddressSanitizer|runtime error' <<<"$OUT"; then CRASH="$CRASH $1"; fi
  if [ "$V" = 1 ] && [ "${3:-}" != quiet ]; then echo; echo "-- scenario $1, input: $2 (exit $CODE) --"; sed -n '1,42p' <<<"$STU" | cut -c1-118; fi
}
arr_qty() { grep "^ARR|$1|" <<<"$ARR" | cut -d'|' -f6; }
hasnum() { perl -e 'my ($w,$t)=@ARGV; for my $x ($t =~ /-?\d+(?:\.\d+)?/g) { exit 0 if abs($x-$w) < 0.005 } exit 1' "$1" "$2"; }
has() { grep -qF -- "$1" <<<"$2"; }
notmsg() { grep -qiE "not |no |n't|cannot|couldn|invalid|unknown|unable|missing" <<<"$1"; }
noslip() { ! grep -qiE 'sub *total' <<<"$1"; }
haspause() { grep -v '^[[:space:]]*$' <<<"$1" | tail -n 3 | grep -qiE 'enter|press|key|continue'; }
total_last() { # text wanted-total
  local lines n p prev
  lines=$(grep -v '^[[:space:]]*$' <<<"$1"); n=$(wc -l <<<"$lines")
  p=$(grep -n -iE 'enter|press|key|continue' <<<"$lines" | tail -1 | cut -d: -f1)
  if [ -n "$p" ] && [ "$p" -gt 1 ] && [ "$p" -ge $((n - 2)) ]; then prev=$(sed -n "$((p-1))p" <<<"$lines"); else prev=$(tail -n 1 <<<"$lines"); fi
  hasnum "$2" "$prev"
}
order_of() { grep -o -E 'Alpha|Bravo|Charlie|Delta|Echo|Foxtrot' <<<"$1" | tr '\n' ' ' | sed 's/ $//'; }

# the seeded books, by slot (slot 4 is a deleted book that kept its old numbers)
TI=(Alpha Bravo Charlie Delta "" Echo Foxtrot); IS=(1-111-11111-1 2-222-22222-2 3-333-33333-3 4-444-44444-4 "" 5-555-55555-5 6-666-66666-6)
AU=(AuthorA AuthorB AuthorC AuthorD "" AuthorE AuthorF); PU=(PressA PressB PressC PressD "" PressE PressF)
DA=(03-15-2021 01-10-2022 11-05-2019 07-20-2020 "" 03-02-2021 12-31-2019); QT=(5 12 1 8 0 3 2)
WH=(10 7.5 22 3 0 12 5.5); RT=(20 15 40 6 0 25 11)
missing_fields() { # text, then field names
  local text="$1"; shift; local out="" s f
  for s in 0 1 2 3 5 6; do
    for f in "$@"; do
      case $f in
        title) has "${TI[$s]}" "$text" || out="$out ${TI[$s]}:title";;
        isbn) has "${IS[$s]}" "$text" || out="$out ${TI[$s]}:ISBN";;
        author) has "${AU[$s]}" "$text" || out="$out ${TI[$s]}:author";;
        publisher) has "${PU[$s]}" "$text" || out="$out ${TI[$s]}:publisher";;
        date) has "${DA[$s]}" "$text" || out="$out ${TI[$s]}:date-added";;
        qty) hasnum "${QT[$s]}" "$text" || out="$out ${TI[$s]}:quantity";;
        wholesale) hasnum "${WH[$s]}" "$text" || out="$out ${TI[$s]}:wholesale";;
        retail) hasnum "${RT[$s]}" "$text" || out="$out ${TI[$s]}:retail";;
      esac
    done
  done
  echo "$out"
}
notfields() { [ -z "$(missing_fields "$@")" ]; }
no_deleted() { ! has "12-31-2023" "$1" && ! hasnum 99 "$1" && ! hasnum 199 "$1"; }
same_arr() { [ "$ARR" = "$BASE" ]; }

run_s none "3\n" quiet; BASE="$ARR"

# ---------- cashier: find the kind of yes/no answer this program uses ----------
YES=1; NO=2; SCHEME_FOUND=0; H0="$HANG"; X0="$CRASH"
for sc in "1 2" "1 0" "y n" "Y N"; do
  set -- $sc
  run_s cash "1\n05/24/26\n1-111-11111-1\n2\n$2\n$2\n" quiet
  if [ "$(arr_qty 0)" = 3 ]; then YES=$1; NO=$2; SCHEME_FOUND=1; break; fi
done
HANG="$H0"; CRASH="$X0"
if [ "$V" = 1 ]; then echo; echo "yes/no answers used by the cashier: $YES / $NO (found: $SCHEME_FOUND)"; fi
SCHEME_HINT="The check types the date, then the ISBN, then the quantity, then your yes/no answers. Use one kind of answer (all 1 and 2, all 1 and 0, all y and n, or all Y and N) for every yes/no question in the cashier."

echo; echo "Cashier: one-title sale"
run_s cash "1\n05/24/26\n1-111-11111-1\n2\n$NO\n$NO\n"; ONE="$STU"; ONE_ARR="$ARR"
c1a() { [ "$SCHEME_FOUND" = 1 ] && has Alpha "$ONE" && hasnum 20 "$ONE"; }
chk C1a "A sale finds the book from its ISBN and shows its title and price" "After the ISBN is typed, search the isbn array, then show the title from bookTitle and the price from retail. $SCHEME_HINT" c1a
c1b() { hasnum 40 "$ONE" && hasnum 2.4 "$ONE" && hasnum 42.4 "$ONE" && grep -qE '2\.40' <<<"$ONE" && grep -qE '42\.40' <<<"$ONE"; }
chk C1b "A one-title sale prints the right subtotal, tax, and total (40.00, 2.40, 42.40)" "Quantity times price is the subtotal, tax is 6% of it, and each amount prints with two decimals." c1b
ARR="$ONE_ARR"; chk C1c "The quantity sold is subtracted from the stock" "When there are enough copies, subtract the quantity bought from qtyOnHand at the book's subscript." bash -c '[ "$1" = 3 ]' _ "$(arr_qty 0)"

echo; echo "Cashier: several titles"
run_s cash "1\n05/24/26\n1-111-11111-1\n2\n$YES\n2-222-22222-2\n1\n$NO\n$NO\n"; TWO="$STU"; TWO_ARR="$ARR"
SLIP=$(grep -n -iE 'ISBN.*Title.*Price|Qty.*ISBN' <<<"$TWO" | tail -1 | cut -d: -f1); if [ -n "$SLIP" ]; then SLIPTXT=$(sed -n "$SLIP,\$p" <<<"$TWO"); else SLIPTXT="$TWO"; fi
chk C2a "A second title can be added to the sale, and both titles are on the slip" "After each title, ask whether another title is being bought. On yes, take another book. On no, print one slip that lists every title. $SCHEME_HINT" bash -c 'grep -qF Alpha <<<"$1" && grep -qF Bravo <<<"$1"' _ "$SLIPTXT"
chk C2b "Each title is on its own row of the slip" "Print a newline after each row of the slip, so the second title does not start on the first title's line." bash -c '! grep -E "Alpha.*Bravo|Bravo.*Alpha" <<<"$1" >/dev/null && grep -qF Alpha <<<"$1" && grep -qF Bravo <<<"$1"' _ "$SLIPTXT"
c2c() { hasnum 55 "$TWO" && hasnum 3.3 "$TWO" && hasnum 58.3 "$TWO"; }
chk C2c "The subtotal, tax, and total include both titles (55.00, 3.30, 58.30)" "Add up every title's line total for the subtotal, then take 6% for the tax. Each amount prints with two decimals." c2c

echo; echo "Cashier: ISBN not found"
run_s cash "1\n05/24/26\n9-999-99999-9\n$NO\n$NO\n"; NF="$STU"; NF_ARR="$ARR"
ARR="$NF_ARR"; chk C3a "An ISBN that is not in inventory gets a message and a chance to enter it again" "If the ISBN is not found, say so and ask whether to enter the ISBN again." bash -c 'grep -qiE "not |no |n.t |cannot|invalid|unknown" <<<"$1" && grep -qiE "again|re-?enter|retry|try" <<<"$1"' _ "$NF"
ARR="$NF_ARR"; chk C3c "Declining to enter the ISBN again returns without selling anything" "If the user says no, stop without a sale: no slip, and no change to qtyOnHand." bash -c '[ "$1" = "$2" ] && ! grep -qiE "sub *total" <<<"$3"' _ "$ARR" "$BASE" "$NF"
run_s cash "1\n05/24/26\n9-999-99999-9\n$YES\n3-333-33333-3\n1\n$NO\n$NO\n"; NR="$STU"
chk C3b "Entering the ISBN again works and the sale goes through" "If the user says yes, ask for the ISBN again and go on with the sale as usual." bash -c '[ "$1" = 0 ] && grep -qF Charlie <<<"$2"' _ "$(arr_qty 2)" "$NR"

echo; echo "Cashier: stock"
run_s cash "1\n05/24/26\n3-333-33333-3\n5\n$NO\n$NO\n"; ST="$STU"; ST_ARR="$ARR"
ARR="$ST_ARR"; chk C4a "Asking for more copies than are in stock shows a message, prints no slip, and changes nothing" "If quantity is more than qtyOnHand, show a message and return to the main menu. Do not print a slip or change the stock. The message needs a word like not enough, insufficient, or stock." bash -c '[ "$1" = "$2" ] && ! grep -qiE "sub *total" <<<"$3" && grep -qiE "not enough|insufficient|only|stock|enough|sorry|available|short" <<<"$3"' _ "$ARR" "$BASE" "$ST"

echo; echo "Cashier: safe processing"
run_s cash "1\n05/24/26\n\n$NO\n$NO\n"; EM="$STU"; EM_ARR="$ARR"
ARR="$EM_ARR"; chk C5a "Pressing Enter at the ISBN prompt does not sell a book" "A deleted book has an empty ISBN, so an empty ISBN must count as not found. Only match an ISBN that is not empty." bash -c '[ "$1" = "$2" ] && ! grep -qiE "sub *total" <<<"$3"' _ "$ARR" "$BASE" "$EM"
LONG="1\n05/24/26\n"; for k in $(seq 1 25); do LONG="${LONG}1-111-11111-1\n1\n$YES\n"; done; for k in $(seq 1 14); do LONG="${LONG}$NO\n"; done
run_s cash21 "$LONG" quiet; L21_CODE=$CODE; L21_OUT="$OUT"
L21_BAD=0; [ "$L21_CODE" != 0 ] && L21_BAD=1; grep -qE 'AddressSanitizer|runtime error' <<<"$L21_OUT" && L21_BAD=1
chk C5b "A sale with more titles than the arrays can hold does not crash" "The arrays that hold a sale's titles have 20 slots. Stop taking titles when the sale is full, so the program never writes past slot 19." bash -c '[ "$1" = 0 ]' _ "$L21_BAD"
if [ "$V" = 1 ]; then echo; echo "-- scenario cash21 (25 titles typed, exit $L21_CODE) --"; grep -E "full|more titles|Thank|ERROR|runtime error" <<<"$L21_OUT" | head -4; fi

# ---------- the reports ----------
rep() { run_s "$1" "3\n01-01-26\n\n"; }
echo; echo "repListing"
rep listing; R="$STU"
chk L1 "repListing shows all eight fields for every book" "Show the title, ISBN, author, publisher, date added, quantity on hand, wholesale cost, and retail price of every book." notfields "$R" title isbn author publisher date qty wholesale retail
chk L2 "repListing shows the date that was typed" "Ask for today's date with cin >> and show it in the report title." has "01-01-26" "$R"
chk L3 "repListing skips deleted books" "A deleted book has an empty ISBN. Do not show books whose ISBN is empty." no_deleted "$R"
chk L4 "repListing ends with a pause that asks the user to press Enter" "After the report, show a message such as Press Enter to continue, and wait." haspause "$R"

echo; echo "repWholesale"
rep wholesale; R="$STU"
chk W1 "repWholesale shows the title, ISBN, quantity, and wholesale cost of every book" "Show title, ISBN, quantity on hand, and wholesale cost for every book." notfields "$R" title isbn qty wholesale
chk W2 "repWholesale shows the date that was typed" "Ask for today's date with cin >> and show it in the report title." has "01-01-26" "$R"
chk W3 "repWholesale skips deleted books" "Do not show or count books whose ISBN is empty." no_deleted "$R"
chk W4 "The total wholesale value is correct (233.00)" "Total = wholesale cost times quantity, added up for every book that is not deleted." hasnum 233 "$R"
chk W5 "The total is the last line of the report" "Print the total as the last line of the report. Do not print anything like End of report after it." total_last "$R" 233
chk W6 "repWholesale ends with a pause that asks the user to press Enter" "After the report, show a message such as Press Enter to continue, and wait." haspause "$R"

echo; echo "repRetail"
rep retail; R="$STU"
chk R1 "repRetail shows the title, ISBN, quantity, and retail price of every book" "Show title, ISBN, quantity on hand, and retail price for every book." notfields "$R" title isbn qty retail
chk R2 "repRetail shows the date that was typed" "Ask for today's date with cin >> and show it in the report title." has "01-01-26" "$R"
chk R3 "repRetail skips deleted books" "Do not show or count books whose ISBN is empty." no_deleted "$R"
chk R4 "The total retail value is correct (465.00)" "Total = retail price times quantity, added up for every book that is not deleted." hasnum 465 "$R"
chk R5 "The total is the last line of the report" "Print the total as the last line of the report. Do not print anything like End of report after it." total_last "$R" 465
chk R6 "repRetail ends with a pause that asks the user to press Enter" "After the report, show a message such as Press Enter to continue, and wait." haspause "$R"

sortinfo() { # label order-got order-wanted
  [ "$V" = 1 ] && { echo "   order shown:  $2"; echo "   order wanted: $3"; }
}
echo; echo "repQty"
rep qty; R="$STU"; QA="$ARR"; ORD=$(order_of "$R"); sortinfo q "$ORD" "Bravo Delta Alpha Echo Foxtrot Charlie"
chk Q1 "repQty lists the books from the largest quantity to the smallest" "Sort by quantity on hand, largest first. Compare the values the pointers point to (*p), not the pointers." bash -c '[ "$1" = "Bravo Delta Alpha Echo Foxtrot Charlie" ]' _ "$ORD"
chk Q2 "repQty shows the title, ISBN, and quantity of every book" "Show title, ISBN, and quantity on hand for every book." notfields "$R" title isbn qty
chk Q3 "repQty shows the date that was typed" "Ask for today's date with cin >> and show it in the report title." has "01-01-26" "$R"
chk Q4 "repQty skips deleted books" "Do not show books whose ISBN is empty." no_deleted "$R"
chk Q5 "repQty ends with a pause that asks the user to press Enter" "After the report, show a message such as Press Enter to continue, and wait." haspause "$R"
ARR="$QA"

echo; echo "repCost"
rep cost; R="$STU"; KA="$ARR"; ORD=$(order_of "$R"); sortinfo k "$ORD" "Charlie Echo Alpha Bravo Foxtrot Delta"
chk K1 "repCost lists the books from the highest wholesale cost to the lowest" "Sort by wholesale cost, highest first. Compare the values the pointers point to (*p), not the pointers." bash -c '[ "$1" = "Charlie Echo Alpha Bravo Foxtrot Delta" ]' _ "$ORD"
chk K2 "repCost shows the title, ISBN, quantity, and wholesale cost of every book" "Show title, ISBN, quantity on hand, and wholesale cost for every book." notfields "$R" title isbn qty wholesale
chk K3 "repCost shows the date that was typed" "Ask for today's date with cin >> and show it in the report title." has "01-01-26" "$R"
chk K4 "repCost skips deleted books" "Do not show books whose ISBN is empty." no_deleted "$R"
chk K5 "repCost ends with a pause that asks the user to press Enter" "After the report, show a message such as Press Enter to continue, and wait." haspause "$R"

echo; echo "repAge"
rep age; R="$STU"; AA="$ARR"; ORD=$(order_of "$R"); sortinfo a "$ORD" "Charlie Foxtrot Delta Echo Alpha Bravo"
AGE_NOTE=""
[ "$ORD" = "Bravo Echo Alpha Delta Charlie Foxtrot" ] && AGE_NOTE="The order matches comparing the dates as plain MM-DD-YYYY text, so the month sorts before the year."
[ "$ORD" = "Foxtrot Echo Delta Charlie Bravo Alpha" ] && AGE_NOTE="The order is the reverse of the order the books were entered. That is what comparing the pointers (their addresses) gives, not the dates."
[ "$V" = 1 ] && [ -n "$AGE_NOTE" ] && echo "   note: $AGE_NOTE"
chk A1 "repAge lists the books from the oldest date added to the newest" "Sort by date added, oldest first. Dates are MM-DD-YYYY, so compare the year first, then the month, then the day. $AGE_NOTE" bash -c '[ "$1" = "Charlie Foxtrot Delta Echo Alpha Bravo" ]' _ "$ORD"
chk A2 "repAge shows the title, ISBN, quantity, and date added of every book" "Show title, ISBN, quantity on hand, and date added for every book." notfields "$R" title isbn qty date
chk A3 "repAge shows the date that was typed" "Ask for today's date with cin >> and show it in the report title." has "01-01-26" "$R"
chk A4 "repAge skips deleted books" "Do not show books whose ISBN is empty." no_deleted "$R"
chk A5 "repAge ends with a pause that asks the user to press Enter" "After the report, show a message such as Press Enter to continue, and wait." haspause "$R"

# ---------- pointers ----------
echo; echo "Sorting with pointers"
ptrdecl() {
  perl -0777 -e '
    my $name = shift; my $src = <STDIN>;
    $src =~ s{//[^\n]*}{}g; $src =~ s{/\*.*?\*/}{}gs;
    if ($src =~ /\bvoid\s+$name\s*\(\s*\)\s*\{/g) {
      my $start = pos($src); my $depth = 1; my $i = $start;
      while ($depth && $i < length($src)) { my $c = substr($src,$i,1); $depth++ if $c eq "{"; $depth-- if $c eq "}"; $i++; }
      my $body = substr($src, $start, $i - $start);
      exit 0 if $body =~ /\b(?:int|double|float|long|string)\s*\*\s*\w+\s*\[/;
    }
    exit 1;
  ' "$1" < <(cat $CPPS)
}
declare -A DECL
for f in Qty Cost Age; do if ptrdecl "rep$f"; then DECL[$f]=1; else DECL[$f]=0; fi; done
[ "$V" = 1 ] && echo "   arrays of pointers declared inside:  repQty=${DECL[Qty]}  repCost=${DECL[Cost]}  repAge=${DECL[Age]}"
UN_Q=0; [ "$QA" = "$BASE" ] && UN_Q=1; UN_K=0; [ "$KA" = "$BASE" ] && UN_K=1; UN_A=0; [ "$AA" = "$BASE" ] && UN_A=1
pq() { [ "${DECL[Qty]}" = 1 ] && [ "$UN_Q" = 1 ]; }
PQH="Declare an array of pointers (such as int* qtyPtr[SIZE]), point each one at an element of qtyOnHand, and sort the pointers."; [ "${DECL[Qty]}" = 1 ] && PQH="Your data arrays changed after repQty. Sort the pointers, and do not move the values in qtyOnHand or the other arrays."
chk PQ "repQty sorts through an array of pointers and leaves the data arrays in their original order" "$PQH" pq
pk() { [ "${DECL[Cost]}" = 1 ] && [ "$UN_K" = 1 ]; }
PKH="Declare an array of pointers (such as double* wholePtr[SIZE]), point each one at an element of wholesale, and sort the pointers."; [ "${DECL[Cost]}" = 1 ] && PKH="Your data arrays changed after repCost. Sort the pointers, and do not move the values in wholesale or the other arrays."
chk PK "repCost sorts through an array of pointers and leaves the data arrays in their original order" "$PKH" pk
pa() { [ "${DECL[Age]}" = 1 ] && [ "$UN_A" = 1 ]; }
PAH="Declare an array of pointers (such as string* datePtr[SIZE]), point each one at an element of dateAdded, and sort the pointers."; [ "${DECL[Age]}" = 1 ] && PAH="Your data arrays changed after repAge. Sort the pointers, and do not move the values in dateAdded or the other arrays."
chk PA "repAge sorts through an array of pointers and leaves the data arrays in their original order" "$PAH" pa

echo; echo "Safe processing"
HANG=$(echo $HANG | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' '); CRASH=$(echo $CRASH | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ')
chk S1 "No test hung or waited for input forever" "A prompt may be waiting for input that never comes, or a loop never ends. These tests hung: $HANG" bash -c '[ -z "$1" ]' _ "$HANG"
chk S2 "No test crashed or used an array slot outside 0 to 19" "Make sure every loop stays inside the arrays (slots 0 to 19). These tests crashed: $CRASH" bash -c '[ -z "$1" ]' _ "$CRASH"
[ -z "$SAN" ] && echo "  (The memory-safety tools were not available here, so out-of-range access could not be detected.)"

# ---------- teacher view: suggested rubric points ----------
if [ "$V" = 1 ]; then
  r() { echo "${RES[$1]:-0}"; }
  cnt() { local n=0 k; for k in "$@"; do [ "$(r $k)" = 1 ] && n=$((n+1)); done; echo $n; }
  fails() { local n=0 k; for k in "$@"; do [ "$(r $k)" = 0 ] && n=$((n+1)); done; echo $n; }
  s1=$(cnt C2a C2b C2c)
  if [ "$(r C1a)" = 0 ]; then s2=0; elif [ "$(cnt C3a C3b C3c)" = 3 ]; then s2=3; else s2=2; fi
  s3=$(cnt C1c C4a)
  s4=0; [ "$(r C5a)" = 1 ] && [ "$(r C5b)" = 1 ] && s4=1
  s5=0; [ "$(fails L1 L2 L3 L4)" = 0 ] && s5=1
  val() { local f=$(fails "$@"); if [ "$f" = 0 ]; then echo 2; elif [ "$f" -le 2 ]; then echo 1; else echo 0; fi; }
  s6=$(val W1 W2 W3 W4 W5 W6); s7=$(val R1 R2 R3 R4 R5 R6)
  srt() { local o=$1; shift; if [ "$(r $o)" = 0 ]; then echo 0; elif [ "$(fails "$@")" = 0 ]; then echo 2; else echo 1; fi; }
  s8=$(srt Q1 Q2 Q3 Q4 Q5); s9=$(srt K1 K2 K3 K4 K5)
  if [ "$(r A1)" = 0 ]; then if grep -q "plain MM-DD-YYYY" <<<"$AGE_NOTE"; then s10=1; else s10=0; fi; elif [ "$(fails A2 A3 A4 A5)" = 0 ]; then s10=2; else s10=1; fi
  c=0; d=0
  [ "${DECL[Qty]}" = 1 ] && d=$((d+1)); [ "${DECL[Cost]}" = 1 ] && d=$((d+1)); [ "${DECL[Age]}" = 1 ] && d=$((d+1))
  [ "$(r PQ)" = 1 ] && [ "$(r Q1)" = 1 ] && c=$((c+1)); [ "$(r PK)" = 1 ] && [ "$(r K1)" = 1 ] && c=$((c+1)); [ "$(r PA)" = 1 ] && { [ "$(r A1)" = 1 ] || grep -q "plain MM-DD-YYYY" <<<"$AGE_NOTE"; } && c=$((c+1))
  if [ $c = 3 ]; then s11=5; elif [ $d = 3 ] && [ $c = 2 ]; then s11=4; elif [ $c = 2 ]; then s11=3; elif [ $c = 1 ]; then s11=2; elif [ $d -ge 1 ]; then s11=1; else s11=0; fi
  tot=$((s1+s2+s3+s4+s5+s6+s7+s8+s9+s10+s11))
  echo; echo "== RUBRIC MAP (suggested points from these checks; you make the final call) =="
  printf '  %-52s %s\n' "cashier: multiple titles (3)" "$s1"
  printf '  %-52s %s\n' "cashier: ISBN lookup (3)" "$s2"
  printf '  %-52s %s\n' "cashier: stock check (2)" "$s3"
  printf '  %-52s %s\n' "cashier: safe processing (1)" "$s4"
  printf '  %-52s %s\n' "repListing: inventory listing (1)" "$s5"
  printf '  %-52s %s\n' "repWholesale: wholesale value (2)" "$s6"
  printf '  %-52s %s\n' "repRetail: retail value (2)" "$s7"
  printf '  %-52s %s\n' "repQty: listing by quantity (2)" "$s8"
  printf '  %-52s %s\n' "repCost: listing by cost (2)" "$s9"
  printf '  %-52s %s\n' "repAge: listing by age (2)" "$s10"
  printf '  %-52s %s\n' "repQty, repCost, repAge: sort with pointers (5)" "$s11"
  printf '  %-52s %s\n' "TOTAL (25)" "$tot"
  echo "  Not in these checks (read the code): ISBN lookup scoring 1 (only the title or only the price shows), and anything the tests cannot see."
fi
finish