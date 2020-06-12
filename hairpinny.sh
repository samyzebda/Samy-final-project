#!/usr/local/bin/bash
#BASH 5.0.17
help=$'\n\nThis software will take any desired input and construct a hairpin AND logic gate. It will decifer minimum free energy states and output predicted sturctural outcomes'
rules="\n-Sequences should be input 5'-3'\n\n-only sequences of 20nt are processed by each hairpin\n\n-sequences of over 20nt can be input into the programme, but only the 5'-20nt will be used"
#
#
nt[0]="A"
nt[1]="T"
nt[2]="C"
nt[3]="G"
#1) Start : input 
while true; do
	read -p "Enter desired target sequence : " target
#Help	
	if [ $target = "rules" ] ; then
		echo -e "$rules"
	elif [ $target = "help" ] ; then
		echo "$help"
#Taking input seq		
	elif [ ${#target} = 20 ] ; then
		break
#Cut long ones		
	elif [ ${#target} -gt 20 ] ; then
		echo -e "\n\nCutting target sequence...."
		target=$(cut -c 1-20 <<<"$target")
		target=${target^^}
		echo -e "\n\nEffective target sequence : $target"
		break
#Fill short ones		
	elif (( ${#target} <=19 && ${#target} >=5 )) ; then
		echo -e "\n\nFilling target sequence..."
		gap=$((20-${#target}))	
#Random seq generator		
		for i in $(seq 1 $gap) ; do
			n=${#nt[@]}
			t=$(($RANDOM % $n))
			target="${target}${nt[$t]}"
		done	
		target=${target^^}
		echo -e "\nEffective target sequence : $target"
		break
	fi	
done
#2) Hairpin construction
#target-output-toe-input1-input2-toeR-outputR-targetR
#target
targetR=$(echo "$target" | tr ACGT TGCA | rev)
#output - generate
for i in {1..20} ; do
	n=${#nt[@]}
	t=$(($RANDOM % $n))
	output="${output}${nt[$t]}"
done
#output - reverse compliment
outputR=$(echo "$output" | tr ACGT TGCA | rev)
#Toehold and stop
toe="TAAGC"
toeR="GCTTA"
#Input 1 - and reverse compliment
for i in {1..32} ; do
	n=${#nt[@]}
	t=$(($RANDOM % $n))
	input1="${input1}${nt[$t]}"
done
input1R=$(echo "$input1" | tr ACGT TGCA | rev)
#Input 2 - and reverse compliment 
for i in {1..32} ; do
	n=${#nt[@]}
	t=$(($RANDOM % $n))
	input2="${input2}${nt[$t]}"
done
input2R=$(echo "$input2" | tr ACGT TGCA | rev)
#Construct
hairpin="${target}${output}${toe}${input1}${input2}${toeR}${outputR}${inputR}"
#Make file
alias="test"
touch "$alias.in"
echo -e "4">>$alias.in
echo -e "$hairpin">>$alias.in
echo -e "$input1R">>$alias.in
echo -e "$input2R">>$alias.in
echo -e "$targetR">>$alias.in
echo -e "1 3 2 4">>$alias.in
#Determine mfe structure 
mfe -mult $alias
#print conformation
echo "$(sed '16q;d' $alias.mfe)"


















