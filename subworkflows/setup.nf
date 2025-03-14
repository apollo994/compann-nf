include { MAKE_OUT_FOLDERS } from '../modules/make_out_folders'

workflow SETUP {
    main:
        MAKE_OUT_FOLDERS()
    
    emit:
        folders = MAKE_OUT_FOLDERS.out
}
