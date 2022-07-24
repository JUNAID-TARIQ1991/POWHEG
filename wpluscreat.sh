
cd /afs/cern.ch/user/j/jtariq
home=$PWD

inputname1=AMBP16
inputname2=w+

cd $home/POWHEG-BOX-V2/Worigional
Worigional=$PWD
echo $PWD
cd $home/POWHEG-BOX-V2/W
wdir=$PWD
echo '===>'$PWD

if [ -f $inputname1 ]; then
    cd $wdir/$inputname1/
    echo 'file' /$inputname1 'found'
else
    echo 'creating ' $wdir/$inputname1
    mkdir -p $wdir/$inputname1
    cd $wdir/$inputname1/

fi

echo $PWD

if [ -f $inputname2 ]; then
    echo 'directory' $inputname2 'found'
    cd $PWD/$inputname2/
else
    echo 'creating' $PWD/$inputname2
    mkdir -p $inputname2
fi

echo '===>'$PWD
cd $wdir/$inputname1/$inputname2
wp=$PWD
pdfindex=42840
n=42869

echo

while [ $pdfindex -le $n ]; do
    if [ -f $pdfindex ]; then
        echo 'pdfset' $pdfindex 'found'
        cd $wp/$pdf/
    else
        echo 'creating directory' $wp/$pdfindex
        mkdir -p $wp/$pdfindex
        cp -RT $Worigional $wp/$pdfindex/
        cd $wp/$pdfindex/
    fi

    #echo '=========>>'$PWD
    cd $wp/$pdfindex/testrun-wm-lhc-8TeV
    #echo '========>>>>>'$PWD
    #ls
    sed -i -e '2 s/-24/24/g' $wp/$pdfindex/testrun-wm-lhc-8TeV/powheg.input
    sed -i -e '5 s/numevts 100000/numevts 1/g' $wp/$pdfindex/testrun-wm-lhc-8TeV/powheg.input
    sed -i -e '10,11 s/4000d0/6500d0/g' $wp/$pdfindex/testrun-wm-lhc-8TeV/powheg.input
    sed -i -e '13,14 s/21100/'$pdfindex'/g' $wp/$pdfindex/testrun-wm-lhc-8TeV/powheg.input
    #sed -i -e '36 s/#renscfact  1d0/renscfact  0.5/g' $wp/$pdfindex/testrun-wm-lhc-8TeV/powheg.input
    #sed -i -e '37 s/#facscfact  1d0/facscfact  0.5/g' $wp/$pdfindex/testrun-wm-lhc-8TeV/powheg.input

    

    mkdir log

    nohup vim $pdfindex.sh &

    echo "#!/bin/bash" >>$pdfindex.sh
    echo "cd $wp/$pdfindex/testrun-wm-lhc-8TeV" >>$pdfindex.sh

    echo " export LHAPDF_DATA_PATH=\$LHAPDF_DATA_PATH:/afs/cern.ch/user/j/jtariq/Lhapdf6.3.0/share/LHAPDF" >>$pdfindex.sh
    #echo " export LHAPDF_DATA_PATH=\$LHAPDF_DATA_PATH:/cvmfs/sft.cern.ch/lcg/external/lhapdfsets/current/" >>$pdfindex.sh
    echo "  export PATH=\$PATH:/afs/cern.ch/user/j/jtariq/Lhapdf6.3.0/bin/" >>$pdfindex.sh

    echo " export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/afs/cern.ch/user/j/jtariq/Lhapdf6.3.0/lib" >>$pdfindex.sh

    echo "  export PATH=\$PATH:/afs/cern.ch/j/jtariq/Fastjet3.4.0/bin/" >>$pdfindex.sh

    echo "   source /cvmfs/sft.cern.ch/lcg/views/LCG_99/x86_64-centos7-gcc8-opt/setup.sh " >>$pdfindex.sh
    echo "    source /cvmfs/sft.cern.ch/lcg/external/lhapdfsets/current/" >> $pdfindex.sh
    echo "./../pwhg_main" >>$pdfindex.sh

    chmod +x $pdfindex.sh

    nohup vim $pdfindex.sub &

	  echo "universe = vanilla" >>$pdfindex.sub
  	  echo "executable =$wp/$pdfindex/testrun-wm-lhc-8TeV/$pdfindex.sh" >>$pdfindex.sub
  	  echo "should_transfer_files = YES" >>$pdfindex.sub
  	  echo "transfer_input_files =$wp/$pdfindex/testrun-wm-lhc-8TeV/powheg.input,$wp/$pdfindex/pwhg_main " >>$pdfindex.sub

   	 echo "log =log/$pdfindex.log" >>$pdfindex.sub
   	 echo "error = log/$pdfindex.error" >>$pdfindex.sub
  	 echo "output =log/$pdfindex.output" >>$pdfindex.sub
  	 echo "When_to_transfer_output = ON_EXIT" >>$pdfindex.sub

   	 echo "+jobflavour="workday" " >>$pdfindex.sub
	 echo "request_cpus  = 8" >> $pdfindex.sub
         echo "request_memory = 4096" >>$pdfindex.sub
  	echo "+MaxRuntime= 7200" >>$pdfindex.sub
        echo "notification = always" >>$pdfindex.sub
#        echo "notify_user = junaid.tariq@cern.ch" >>$pdfindex.sub

        echo "queue 1" >>$pdfindex.sub

    #./$pdfindex.sh

    condor_submit $pdfindex.sub

    cd $wp
    ((pdfindex = pdfindex + 1))

done

