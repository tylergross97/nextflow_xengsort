process XENGSORT_SUMMARY {
    publishDir "${params.outdir_base}/xengsort", mode: 'copy'
    
    input:
    path classification_files
    
    output:
    path "xengsort_summary.csv", emit: summary
    
    script:
    """
    #!/bin/bash
    
    # Output file
    output="xengsort_summary.csv"
    
    # Write header
    echo "prefix,host,graft,ambiguous,both,neither,total,host_pct,graft_pct,ambiguous_pct,both_pct,neither_pct" > "\$output"
    
    # Loop through each xengsort output file
    for file in *.xengsort.txt; do
        # Check if files exist (in case no matches)
        if [[ ! -f "\$file" ]]; then
            continue
        fi
        
        # Extract the count line from the summary block
        stats_line=\$(awk '/^prefix\\t/{getline; print}' "\$file")
        
        # Skip if not found
        if [[ -z "\$stats_line" ]]; then
            echo "Warning: No stats line found in \$file"
            continue
        fi
        
        # Read values into variables
        IFS=\$'\\t' read -r prefix host graft ambiguous both neither <<< "\$stats_line"
        
        # Calculate total
        total=\$((host + graft + ambiguous + both + neither))
        
        # Calculate percentages with awk
        read host_pct graft_pct ambiguous_pct both_pct neither_pct <<< \$(awk -v h=\$host -v g=\$graft -v a=\$ambiguous -v b=\$both -v n=\$neither -v t=\$total \\
            'BEGIN { printf "%.2f %.2f %.2f %.2f %.2f", (h/t)*100, (g/t)*100, (a/t)*100, (b/t)*100, (n/t)*100 }')
        
        # Append to CSV
        echo "\$prefix,\$host,\$graft,\$ambiguous,\$both,\$neither,\$total,\$host_pct,\$graft_pct,\$ambiguous_pct,\$both_pct,\$neither_pct" >> "\$output"
    done
    
    echo "✅ Summary written to \$output"
    """
}
