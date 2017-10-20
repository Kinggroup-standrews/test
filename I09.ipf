#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function HDF5TEST(path, filename)
	string path,filename
	string fname
	variable fileID, dash
	
	wave BE, y_Scale
	
	
//	if(strsearch(filename,"-",0)!=-1)
//			fname=replacestring("-", filename, "_")
//	endif
	hdf5openfile /P=$path/R fileID as filename
	HDF5LoadData /O/Q/N=$fname fileID, "entry1/VB_swept/spectrum"
	HDF5LoadData /O/Q/N=BE fileID, "entry1/VB_swept/binding_energy"
	HDF5LoadData /O/Q/N=y_Scale fileID, "entry1/VB_swept/y_scale"
	
	wave spectrum = $fname
//	sleep /T 120
	setscale /I y, BE[0], BE[numpnts(BE)-1], spectrum
	setscale /I x, y_Scale[0], y_Scale[numpnts(y_Scale)-1], spectrum
	killwaves /Z BE, y_scale
	
end


Function load_NeXus_HDF5_files_i09_ori(symPath, FileName)
	//Loading of NeXus HDF5 files
	String symPath, FileName
	string noteStr = i_photo2_KeyList(0)
	variable ii
	
	String DF = GetDataFolder (1)
	
	SetDataFolder root:
	NewDataFolder/O/S carpets
	NewDataFolder/O rawData
	NewDataFolder/O Transformed
	
	SetDataFolder root:
	NewDataFolder /s/o root:temp_load
	
	//Nickname of file
	string NickName = fileName_to_waveName(fileName,"pref")
	
	///////////////////////////////////////////////////////////
	// this part taken from macro of Mathias Muntwiler
	// open file
  	variable fileID
 	HDF5OpenFile /P=$symPath/R fileID as FileName
  	if (v_flag == 0)
   		print "loading " + FileName + "\r"
    		FileName = s_path + s_filename

    		// get first group path
   		HDF5ListGroup /F/TYPE=1 fileID, "/"
   		string entrypath = StringFromList(0, S_HDF5ListGroup, ";")
//		print "Entry path is " + entrypath + "\r"
		
		string analyserdatapath = entrypath + "/instrument/analyser"
//		string region_name
		HDF5LoadData /O/Q/N=Region_name fileID, entrypath+"/instrument/analyser/region_list"
//		region_name=region_list[0]
		wave /T region_name
		print Region_name[0]
		
//		print "analyser data path is " + analyserdatapath + "\r"

		// TODO Bail out with message if no analyser data in file	
		
   		 // get list of datasets
 		 HDF5ListGroup /F/TYPE=2 fileID, analyserdatapath
 		 variable nds = ItemsInList(S_HDF5ListGroup, ";")
 		 variable ids
 		 for (ids = 0; ids < nds; ids += 1)
   			   HDF5LoadData /O/Q fileID, StringFromList(ids, S_HDF5ListGroup, ";")
   		endfor

		HDF5LoadData /O/Q fileID, entrypath+"/instrument/"+region_name[0]+"/pass_energy"
  		HDF5LoadData /O/Q fileID, entrypath+"/instrument/"+region_name[0]+"/acquisition_mode"		
		HDF5LoadData /O/Q fileID, entrypath+"/instrument/"+region_name[0]+"/lens_mode"
		HDF5LoadData /O/Q/N=instrument_name fileID, entrypath+"/instrument/name"
		HDF5LoadData /O/Q/N=photon_energy fileID, entrypath+"/instrument/"+region_name[0]+"/photon_energy"
		HDF5LoadData /O/Q/N=software fileID, entrypath+"/program_name"
		HDF5LoadData /O/Q/N=sample fileID, entrypath+"/title"
//		HDF5LoadData /O/Q/N=sampletemp fileID, entrypath+"/instrument/lakeshore/\"sample\""
//		HDF5LoadData /O/Q/N=slit fileID, entrypath+"/instrument/analyser/entrance_slit_setting"
		HDF5LoadData /O/Q/N=sax fileID, entrypath+"/instrument/hsmpm/hsmpmx"
		HDF5LoadData /O/Q/N=say fileID, entrypath+"/instrument/hsmpm/hsmpmy"
		HDF5LoadData /O/Q/N=saz fileID, entrypath+"/instrument/hsmpm/hsmpmz"
		HDF5LoadData /O/Q/N=sapolar fileID, entrypath+"/instrument/hsmpm/hsmpmpolar"
		HDF5LoadData /O/Q/N=satilt fileID, entrypath+"/instrument/hsmpm/hsmpmtilt"
		HDF5LoadData /O/Q/N=saazimuth fileID, entrypath+"/instrument/hsmpm/hsmpmazi"
   		HDF5CloseFile fileID
	else
    		FileName = ""
	endif
	///////////////////////////////////////////////////////////

	wave data, energies, angles, location, pass_energy,photon_energy,sampletemp,sax,say,saz,sapolar,satilt,saazimuth
	wave/t acquisition_mode,lens_mode,instrument_name,software,sample,slit
	
	noteStr = ReplaceStringByKey("FileName",noteStr,FileName,"=","\r")
	noteStr = ReplaceStringByKey("Sample",noteStr,sample[0],"=","\r")
	//noteStr = ReplaceStringByKey("Comments",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("StartDate",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("StartTime",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("Instrument",noteStr,instrument_name[0],"=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware",noteStr,software[0],"=","\r")
	//noteStr = ReplaceStringByKey("User",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("KineticEnergy",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy",noteStr,num2str(pass_energy[0]),"=","\r")
	//noteStr = ReplaceStringByKey("DwellTime",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("LensMode",noteStr,lens_mode[0],"=","\r")
//	noteStr = ReplaceStringByKey("EntranceSlit",noteStr,slit[0],"=","\r")
	noteStr = ReplaceStringByKey("PhotonEnergy",noteStr,num2str(photon_energy[0]),"=","\r")
//	noteStr = ReplaceStringByKey("SampleTemperature",noteStr,num2str(sampletemp[0]),"=","\r")
	//noteStr = ReplaceStringByKey("FirstEnergy",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("LastEnergy",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("InitialThetaManipulator",noteStr,num2str(sapolar[0]),"=","\r")
	noteStr = ReplaceStringByKey("InitialPhiManipulator",noteStr,num2str(satilt[0]),"=","\r")
	noteStr = ReplaceStringByKey("InitialAzimuthManipulator",noteStr,num2str(saazimuth[0]),"=","\r")

	//Note data, noteStr
	
	//Check number of layers
	variable nl = DimSize(data,0)
	
		for(ii=0;ii<nl;ii+=1)
			String nap, nap2
			nap = num2str(1000+ii)
			nap2 = nap[1,3]
			make/O/n=(dimsize(data,1),dimsize(data,2)) w = data[ii][p][q]
			duplicate/O w $"root:carpets:rawData:"+nickname+"_"+nap2
			//Set angle/energy scales - this is pants really as it does not use to proper data available just start and step
			if (GrepString(lens_mode[0], "[tT]ransmission"))
				SetScale/P x,location[0],location[1]-location[0],"mm",$"root:carpets:rawData:"+nickname+"_"+nap2
			else
				SetScale/P x,angles[0],angles[1]-angles[0],"deg",$"root:carpets:rawData:"+nickname+"_"+nap2
			endif
			if (dimsize(energies,1)==0)//Check if loading photon-energy dependent data
				SetScale/P y,energies[0],energies[1]-energies[0],"eV",$"root:carpets:rawData:"+nickname+"_"+nap2
			else
				SetScale/P y,energies[ii][0],energies[ii][1]-energies[ii][0],"eV",$"root:carpets:rawData:"+nickname+"_"+nap2
			endif
			
			//Set photon energy correctly in wavenotes
			if (dimsize(photon_energy,0) == nl)	
				noteStr = ReplaceStringByKey("PhotonEnergy",noteStr,num2str(photon_energy[ii]),"=","\r")
			endif		
			
			//Set angles correctly in wavenotes
			if (dimsize(sapolar,0) == nl)
				noteStr = ReplaceStringByKey("InitialThetaManipulator",noteStr,num2str(sapolar[ii]),"=","\r")
				noteStr = ReplaceStringByKey("InitialPhiManipulator",noteStr,num2str(satilt[ii]),"=","\r")
				noteStr = ReplaceStringByKey("InitialAzimuthManipulator",noteStr,num2str(saazimuth[ii]),"=","\r")
			endif
				
			Note $"root:carpets:rawData:"+nickname+"_"+nap2, noteStr
		endfor
		
	print "End of loading NeXus file"
	KillDataFolder root:temp_load
	
	SetDataFolder $DF
End


Function load_NeXus_HDF5_files_i09(symPath, FileName)
	//Loading of NeXus HDF5 files
	String symPath, FileName
	string noteStr = i_photo2_KeyList(0)
	variable ii
	
	String DF = GetDataFolder (1)
	
	SetDataFolder root:
	NewDataFolder/O/S carpets
	NewDataFolder/O rawData
	NewDataFolder/O Transformed
	
	SetDataFolder root:
	NewDataFolder /s/o root:temp_load
	
	//Nickname of file
	string NickName = fileName_to_waveName(fileName,"pref")
	
	///////////////////////////////////////////////////////////
	// this part taken from macro of Mathias Muntwiler
	// open file
  	variable fileID
 	HDF5OpenFile /P=$symPath/R fileID as FileName
  	if (v_flag == 0)
   		print "loading " + FileName + "\r"
    		FileName = s_path + s_filename

    		// get first group path
   		HDF5ListGroup /F/TYPE=1 fileID, "/"
   		string entrypath = StringFromList(0, S_HDF5ListGroup, ";")
//		print "Entry path is " + entrypath + "\r"
		
		string analyserdatapath = entrypath + "/instrument/analyser"
//		string region_name
		HDF5LoadData /O/Q/N=Region_name fileID, entrypath+"/instrument/analyser/region_list"
//		region_name=region_list[0]
		wave /T region_name
		print Region_name[0]
		
//		print "analyser data path is " + analyserdatapath + "\r"

		// TODO Bail out with message if no analyser data in file	
		
   		 // get list of datasets
// 		 HDF5ListGroup /F/TYPE=2 fileID, analyserdatapath
// 		 variable nds = ItemsInList(S_HDF5ListGroup, ";")
// 		 variable ids
// 		 for (ids = 0; ids < nds; ids += 1)
//   			   HDF5LoadData /O/Q fileID, StringFromList(ids, S_HDF5ListGroup, ";")
//   		endfor

		HDF5LoadData /O/Q/N=data fileID, entrypath+"/"+region_name[0]+"/image"
		HDF5LoadData /O/Q/N=angles fileID, entrypath+"/"+region_name[0]+"/y_scale"
		HDF5LoadData /O/Q/N=energies fileID, entrypath+"/"+region_name[0]+"/binding_energy"
		HDF5LoadData /O/Q/N=data fileID, entrypath+"/"+region_name[0]+"/image"
		HDF5LoadData /O/Q fileID, entrypath+"/instrument/"+region_name[0]+"/pass_energy"
  		HDF5LoadData /O/Q fileID, entrypath+"/instrument/"+region_name[0]+"/acquisition_mode"		
		HDF5LoadData /O/Q fileID, entrypath+"/instrument/"+region_name[0]+"/lens_mode"
		HDF5LoadData /O/Q/N=instrument_name fileID, entrypath+"/instrument/name"
		HDF5LoadData /O/Q/N=photon_energy fileID, entrypath+"/instrument/"+region_name[0]+"/photon_energy"
		HDF5LoadData /O/Q/N=software fileID, entrypath+"/program_name"
		HDF5LoadData /O/Q/N=sample fileID, entrypath+"/title"
//		HDF5LoadData /O/Q/N=sampletemp fileID, entrypath+"/instrument/lakeshore/\"sample\""
//		HDF5LoadData /O/Q/N=slit fileID, entrypath+"/instrument/analyser/entrance_slit_setting"
		HDF5LoadData /O/Q/N=sax fileID, entrypath+"/instrument/hsmpm/hsmpmx"
		HDF5LoadData /O/Q/N=say fileID, entrypath+"/instrument/hsmpm/hsmpmy"
		HDF5LoadData /O/Q/N=saz fileID, entrypath+"/instrument/hsmpm/hsmpmz"
		HDF5LoadData /O/Q/N=sapolar fileID, entrypath+"/instrument/hsmpm/hsmpmpolar"
		HDF5LoadData /O/Q/N=satilt fileID, entrypath+"/instrument/hsmpm/hsmpmtilt"
		HDF5LoadData /O/Q/N=saazimuth fileID, entrypath+"/instrument/hsmpm/hsmpmazi"
   		HDF5CloseFile fileID
	else
    		FileName = ""
	endif
	///////////////////////////////////////////////////////////

	wave data, energies, angles, location, pass_energy,photon_energy,sampletemp,sax,say,saz,sapolar,satilt,saazimuth
	wave/t acquisition_mode,lens_mode,instrument_name,software,sample,slit
	
	noteStr = ReplaceStringByKey("FileName",noteStr,FileName,"=","\r")
	noteStr = ReplaceStringByKey("Sample",noteStr,sample[0],"=","\r")
	//noteStr = ReplaceStringByKey("Comments",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("StartDate",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("StartTime",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("Instrument",noteStr,instrument_name[0],"=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware",noteStr,software[0],"=","\r")
	//noteStr = ReplaceStringByKey("User",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("KineticEnergy",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy",noteStr,num2str(pass_energy[0]),"=","\r")
	//noteStr = ReplaceStringByKey("DwellTime",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("LensMode",noteStr,lens_mode[0],"=","\r")
//	noteStr = ReplaceStringByKey("EntranceSlit",noteStr,slit[0],"=","\r")
	noteStr = ReplaceStringByKey("PhotonEnergy",noteStr,num2str(photon_energy[0]),"=","\r")
//	noteStr = ReplaceStringByKey("SampleTemperature",noteStr,num2str(sampletemp[0]),"=","\r")
	//noteStr = ReplaceStringByKey("FirstEnergy",noteStr,Parameters[V_value][1],"=","\r")
	//noteStr = ReplaceStringByKey("LastEnergy",noteStr,Parameters[V_value][1],"=","\r")
	noteStr = ReplaceStringByKey("InitialThetaManipulator",noteStr,num2str(sapolar[0]),"=","\r")
	noteStr = ReplaceStringByKey("InitialPhiManipulator",noteStr,num2str(satilt[0]),"=","\r")
	noteStr = ReplaceStringByKey("InitialAzimuthManipulator",noteStr,num2str(saazimuth[0]),"=","\r")

	//Note data, noteStr
	
	SetScale/I x,satilt[0],satilt[dimsize(satilt,0)-1],"degree",data

	
	//Check number of layers
	variable nl = DimSize(data,0)
	
		for(ii=0;ii<nl;ii+=1)
			String nap, nap2
			nap = num2str(1000+ii)
			nap2 = nap[1,3]
			make/O/n=(dimsize(data,1),dimsize(data,2)) w = data[ii][p][q]
			duplicate/O w $"root:carpets:rawData:"+nickname+"_"+nap2
			SetScale/I x,angles[0],angles[dimsize(angles,0)-1],"degree",$"root:carpets:rawData:"+nickname+"_"+nap2
			SetScale/I y,energies[0],energies[dimsize(energies,0)-1],"eV",$"root:carpets:rawData:"+nickname+"_"+nap2
//			//Set angle/energy scales - this is pants really as it does not use to proper data available just start and step
//			if (GrepString(lens_mode[0], "[tT]ransmission"))
//				SetScale/P x,location[0],location[1]-location[0],"mm",$"root:carpets:rawData:"+nickname+"_"+nap2
//			else
//				SetScale/P x,angles[0],angles[1]-angles[0],"deg",$"root:carpets:rawData:"+nickname+"_"+nap2
//			endif
//			if (dimsize(energies,1)==0)//Check if loading photon-energy dependent data
//				SetScale/P y,energies[0],energies[1]-energies[0],"eV",$"root:carpets:rawData:"+nickname+"_"+nap2
//			else
//				SetScale/P y,energies[ii][0],energies[ii][1]-energies[ii][0],"eV",$"root:carpets:rawData:"+nickname+"_"+nap2
//			endif
//			
//			//Set photon energy correctly in wavenotes
//			if (dimsize(photon_energy,0) == nl)	
//				noteStr = ReplaceStringByKey("PhotonEnergy",noteStr,num2str(photon_energy[ii]),"=","\r")
//			endif		
			
			//Set angles correctly in wavenotes
			if (dimsize(sapolar,0) == nl)
				noteStr = ReplaceStringByKey("InitialThetaManipulator",noteStr,num2str(sapolar[ii]),"=","\r")
				noteStr = ReplaceStringByKey("InitialPhiManipulator",noteStr,num2str(satilt[ii]),"=","\r")
				noteStr = ReplaceStringByKey("InitialAzimuthManipulator",noteStr,num2str(saazimuth[ii]),"=","\r")
			endif
				
			Note $"root:carpets:rawData:"+nickname+"_"+nap2, noteStr
		endfor
		
	print "End of loading NeXus file"
	KillDataFolder root:temp_load
	
	SetDataFolder $DF
End
