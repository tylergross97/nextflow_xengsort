import groovy.json.JsonGenerator
import groovy.json.JsonGenerator.Converter

nextflow.enable.dsl=2

// comes from nf-test to store json files
params.nf_test_output  = ""

// include dependencies


// include test process
include { XENGSORT_CLASSIFY } from '/Users/tylergross/Desktop/nextflow_xengsort/modules/xengsort_classify.nf'

// define custom rules for JSON that will be generated.
def jsonOutput =
    new JsonGenerator.Options()
        .addConverter(Path) { value -> value.toAbsolutePath().toString() } // Custom converter for Path. Only filename
        .build()

def jsonWorkflowOutput = new JsonGenerator.Options().excludeNulls().build()


workflow {

    // run dependencies
    

    // process mapping
    def input = []
    
                input[0] = tuple(
                    [sample: "human"],
                    [
                        file("/Users/tylergross/Desktop/nextflow_xengsort/tests/data/xengsort/human_R1.fastq.gz"),
                        file("/Users/tylergross/Desktop/nextflow_xengsort/tests/data/xengsort/human_R2.fastq.gz")
                    ]
                )
                input[1] = [
                    file("/Users/tylergross/Desktop/nextflow_xengsort/tests/data/xengsort/xengsort_index.hash"),
                    file("/Users/tylergross/Desktop/nextflow_xengsort/tests/data/xengsort/xengsort_index.kmer"),
                    file("/Users/tylergross/Desktop/nextflow_xengsort/tests/data/xengsort/xengsort_index.info")
                ]
                
    //----

    //run process
    XENGSORT_CLASSIFY(*input)

    if (XENGSORT_CLASSIFY.output){

        // consumes all named output channels and stores items in a json file
        for (def name in XENGSORT_CLASSIFY.out.getNames()) {
            serializeChannel(name, XENGSORT_CLASSIFY.out.getProperty(name), jsonOutput)
        }	  
      
        // consumes all unnamed output channels and stores items in a json file
        def array = XENGSORT_CLASSIFY.out as Object[]
        for (def i = 0; i < array.length ; i++) {
            serializeChannel(i, array[i], jsonOutput)
        }    	

    }
  
}

def serializeChannel(name, channel, jsonOutput) {
    def _name = name
    def list = [ ]
    channel.subscribe(
        onNext: {
            list.add(it)
        },
        onComplete: {
              def map = new HashMap()
              map[_name] = list
              def filename = "${params.nf_test_output}/output_${_name}.json"
              new File(filename).text = jsonOutput.toJson(map)		  		
        } 
    )
}


workflow.onComplete {

    def result = [
        success: workflow.success,
        exitStatus: workflow.exitStatus,
        errorMessage: workflow.errorMessage,
        errorReport: workflow.errorReport
    ]
    new File("${params.nf_test_output}/workflow.json").text = jsonWorkflowOutput.toJson(result)
    
}
