for m in $(ls -1d tests/*/)
  do
    tflint \
      --config .tflint.hcl \
      ./${m}
  done
