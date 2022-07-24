#/bin/bash

echo  "***********POWHEG BOX V2*********"

cd /afs/cern.ch/user/j/jtariq

home=$PWD
inputname1=AMBP16
cd $home/POWHEG-BOX-V2/Zorigional
Zorigional=$PWD
echo $PWD
cd $home/POWHEG-BOX-V2/Z 
zdir=$PWD

if [ -f $inputname1 ]; then
    cd $zdir/$inputname1/
    echo 'file' /$inputname1 'found'
else
    echo 'creating ' $zdir/$inputname1
    mkdir -p $zdir/$inputname1
    cd $zdir/$inputname1/
fi  
pdfindex=42840
n=42869
while [ $pdfindex -le $n ]; do
        if [ -f $pdfindex ]; then
            echo 'pdfset' $pdfindex 'found'
            cd $zdir/$inputname1/$pdfindex
        else
            echo 'creating directory' $zdir/$inputname1/$pdfindex
            mkdir -p $zdir/$inputname1/$pdfindex
            cp -RT $Zorigional $zdir/$inputname1/$pdfindex/
            cd $zdir/$inputname1/$pdfindex
        fi

        #echo '=========>>'$PWD
        cd $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV

        #echo '========>>>>>'$PWD
        #ls
        #sed -i -e '2 s/-24/24/g' $wm/$pdfindex/testrun-lhc-8TeV/powheg.input
        sed -i -e '4 s/numevts 100000/numevts 1/g' $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV/powheg.input
  
         sed -i -e '09,10 s/4000d0/6500d0/g' $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV/powheg.input
         sed -i -e '12,13 s/21100/'$pdfindex'/g' $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV/powheg.input
	 #sed -i -e '35 s/#renscfact  1d0/renscfact  0.5/g' $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV/powheg.input
         #sed -i -e '36 s/#facscfact  1d0/facscfact  0.5/g' $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV/powheg.input
      	mkdir log
 
	 nohup vim $pdfindex.sh &
	
	echo "#!/bin/bash" >> $pdfindex.sh
	echo    "cd $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV" >> $pdfindex.sh

	echo "  export LHAPDF_DATA_PATH=\$LHAPDF_DATA_PATH:/afs/cern.ch/user/j/jtariq/Lhapdf6.3.0/share/LHAPDF" >>$pdfindex.sh
        echo "  export PATH=\$PATH:/afs/cern.ch/user/j/jtariq/Lhapdf6.3.0/bin/" >> $pdfindex.sh


        echo " export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/afs/cern.ch/user/j/jtariq/Lhapdf6.3.0/lib" >> $pdfindex.sh



   	 echo  "  export PATH=\$PATH:/afs/cern.ch/j/jtariq/Fastjet3.4.0/bin/" >> $pdfindex.sh
    	  

	echo "   source /cvmfs/sft.cern.ch/lcg/views/LCG_99/x86_64-centos7-gcc8-opt/setup.sh " >>$pdfindex.sh
       	


	  echo " ./../pwhg_main" >> $pdfindex.sh

	chmod +x $pdfindex.sh	

         nohup vim  $pdfindex.sub &
         
         echo "universe = vanilla" >> $pdfindex.sub
         echo "executable = $zdir/$inputname1/$pdfindex/testrun-lhc-8TeV/$pdfindex.sh" >> $pdfindex.sub
         echo "should_transfer_files = YES" >>$pdfindex.sub
         echo "transfer_input_files =$zdir/$inputname1/$pdfindex/testrun-lhc-8TeV/powheg.input,$zdir/$inputname1/$pdfindex/pwhg_main" >> $pdfindex.sub

	 
	 echo "log =log/$pdfindex.log" >> $pdfindex.sub
         echo "error = log/$pdfindex.error" >> $pdfindex.sub
         echo "output =log/$pdfindex.output" >> $pdfindex.sub
         echo "When_to_transfer_output = ON_EXIT" >>$pdfindex.sub
         echo "request_cpus   = 8" >> $pdfindex.sub

         echo "+jobflavour="workday"" >>$pdfindex.sub
       	echo "+MaxRuntime= 3600" >>$pdfindex.sub

         echo "notification = always" >> $pdfindex.sub
       #  echo "notify_user = junaid.tariq@cern.ch" >>$pdfindex.sub
         

         echo "queue 1" >> $pdfindex.sub
        

	 #./$pdfindex.sh

	 condor_submit $pdfindex.sub 

	((pdfindex = pdfindex + 1))
        cd $zdir/$inputname1/

done



