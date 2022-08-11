// This macro was written by Lucille Delisle in collaboration with the BIOP (https://github.com/BIOP)

import ij.*
import ij.measure.Measurements
import ij.plugin.*

import org.ilastik.ilastik4ij.ui.* 

import org.ilastik.ilastik4ij.hdf5.Hdf5DataSetReader
import net.imglib2.img.display.imagej.ImageJFunctions

#@ File(label="Ilastik project") ilastik_project
#@ File(label="input image") input_image
#@ File(label="expected h5 output") output_h5
#@ Float(label="Tolerance", value=40) tolerance
#@ Float(label="Tolerance mean", value=1) tolerance_mean

#@ ResultsTable rt
#@ CommandService cmds
#@ ConvertService cvts
#@ DatasetService ds
#@ DatasetIOService io
#@ LogService ls
#@ StatusService ss

IJ.run("Close All", "")
IJ.run("Clear Results")

def imp = IJ.openImage( input_image.toString() )

println "Starting ilastik";

// can't work without displaying image
// IJ.run("Run Pixel Classification Prediction", "projectfilename="+ilastik_project+" inputimage="+imp.getTitle()+" pixelclassificationtype=Probabilities");
//
// to use in headless_mode more we need to use a commandservice
def predictions_imgPlus = cmds.run( IlastikPixelClassificationCommand.class , false , 
                                    'inputImage' , imp , 
                                    'projectFileName', ilastik_project , 
                                    'pixelClassificationType', "Probabilities").get().getOutput("predictions")                         
// to convert the result to ImagePlus : https://gist.github.com/GenevieveBuckley/460d0abc7c1b13eee983187b955330ba
predictions_imp = ImageJFunctions.wrap(predictions_imgPlus, "predictions") 

println "Ilastik done !";

predictions_imp.setTitle("ilastik_output")

// predictions_imp.show()

// Does not work:
//IJ.run("Import HDF5", "select=/home/ldelisle/Documents/omero/ilastik/recipe/2d_cells_apoptotic_1channel_Probabilities.h5 datasetname=/exported_data axisorderyxc=yxc");


imgPlus = new Hdf5DataSetReader(output_h5.toString(), "/exported_data",
                "yxc", ls, ss).read();

predictions_imp_output = ImageJFunctions.wrap(imgPlus, "predictions") 

predictions_imp_output.setTitle("expected_output")

// predictions_imp_output.show()

ImagePlus imp_diff = ImageCalculator.run(predictions_imp, predictions_imp_output, "Subtract create 32-bit");
// imp_diff.show();
IJ.run("Set Measurements...", "mean min redirect=None decimal=3");
IJ.run(imp_diff, "Measure", "");

min = rt.getValue("Min", 0)
assert -min < tolerance

max = rt.getValue("Max", 0)
assert max < tolerance

mean = rt.getValue("Mean", 0)
assert mean < tolerance_mean
assert -mean < tolerance_mean