def verify_concat_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat_fragment', title).send(:parameters)[:content]
  (content.split("\n") & expected_lines).should == expected_lines
end

def verify_concat_fragment_exact_contents(subject, title, expected_lines)
  content = subject.resource('concat_fragment', title).send(:parameters)[:content]
  content.split(/\n/).reject { |line| line =~ /(^#|^$|^\s+#)/ }.should == expected_lines
end
