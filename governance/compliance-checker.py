#!/usr/bin/env python3
"""
Governance Compliance Checker
Implements automated violation detection per Hoyt's framework
"""

import re
import sys
from typing import List, Dict

class ComplianceChecker:
    def __init__(self):
        self.violations = []
        self.score = 100
        
    def check_response(self, response_text: str, has_test_output: bool = False) -> Dict:
        """Check response against governance rules"""
        
        # Rule 1: MANDATORY-TEST-OUTPUT
        success_claims = self._detect_success_claims(response_text)
        if success_claims and not has_test_output:
            self.violations.append({
                'rule': 'MANDATORY-TEST-OUTPUT',
                'severity': 'CRITICAL',
                'pattern': success_claims,
                'message': 'Claims success without test output'
            })
            self.score -= 75
            
        # Rule 2: 12-LINE-MAXIMUM (narrative check)
        narrative_lines = self._count_narrative_lines(response_text)
        if narrative_lines > 12:
            self.violations.append({
                'rule': '12-LINE-MAXIMUM',
                'severity': 'HIGH',
                'pattern': f'{narrative_lines} narrative lines',
                'message': 'Exceeds 12-line maximum for unrequested content'
            })
            self.score -= 25
            
        # Rule 3: EVIDENCE-REQUIRED
        evidence_ratio = self._calculate_evidence_ratio(response_text)
        if evidence_ratio < 0.5 and success_claims:
            self.violations.append({
                'rule': 'EVIDENCE-REQUIRED',
                'severity': 'HIGH',
                'pattern': f'Evidence ratio: {evidence_ratio:.1%}',
                'message': 'Narrative exceeds evidence (should be >50% evidence)'
            })
            self.score -= 25
            
        # Rule 4: NO-NARRATIVE-SUCCESS
        narrative_success = self._detect_narrative_success(response_text)
        if narrative_success:
            self.violations.append({
                'rule': 'NO-NARRATIVE-SUCCESS',
                'severity': 'MEDIUM',
                'pattern': narrative_success,
                'message': 'Uses narrative success indicators instead of evidence'
            })
            self.score -= 15
            
        return {
            'score': max(0, self.score),
            'violations': self.violations,
            'status': 'PASS' if self.score >= 70 else 'FAIL'
        }
    
    def _detect_success_claims(self, text: str) -> List[str]:
        """Detect claims of success/completion"""
        patterns = [
            r'\b(removed|fixed|complete|ready|restored|added|updated|verified)\b',
        ]
        
        claims = []
        for pattern in patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            claims.extend(matches)
        
        return claims[:5]
    
    def _count_narrative_lines(self, text: str) -> int:
        """Count lines that are narrative (not code/output)"""
        lines = text.split('\n')
        narrative = 0
        
        for line in lines:
            if line.startswith('$') or line.startswith('>>>'):
                continue
            if line.strip().startswith('#'):
                continue
            if re.match(r'^\s*\d+\s+', line):
                continue
            if line.strip() and not line.startswith(' ' * 4):
                narrative += 1
                
        return narrative
    
    def _calculate_evidence_ratio(self, text: str) -> float:
        """Calculate ratio of evidence to narrative"""
        lines = text.split('\n')
        evidence_lines = 0
        total_lines = len([l for l in lines if l.strip()])
        
        if total_lines == 0:
            return 0.0
        
        for line in lines:
            if line.startswith('$') or line.startswith('>>>'):
                evidence_lines += 1
            elif re.match(r'^\s+', line) and line.strip():
                evidence_lines += 1
                
        return evidence_lines / total_lines
    
    def _detect_narrative_success(self, text: str) -> List[str]:
        """Detect narrative success indicators"""
        patterns = [
            r"Successfully \w+",
            r"All \w+ (are|were|have been) \w+",
            r"I('ve| have) \w+ed",
        ]
        
        matches = []
        for pattern in patterns:
            found = re.findall(pattern, text, re.IGNORECASE)
            matches.extend(found)
            
        return matches[:3]

def main():
    if len(sys.argv) < 2:
        print("Usage: compliance-checker.py <response_file> [--has-test-output]")
        sys.exit(1)
        
    response_file = sys.argv[1]
    has_test_output = '--has-test-output' in sys.argv
    
    with open(response_file, 'r') as f:
        response_text = f.read()
    
    checker = ComplianceChecker()
    result = checker.check_response(response_text, has_test_output)
    
    print(f"Compliance Score: {result['score']}/100")
    print(f"Status: {result['status']}")
    print(f"\nViolations Found: {len(result['violations'])}")
    
    for v in result['violations']:
        print(f"\n[{v['severity']}] {v['rule']}")
        print(f"  Pattern: {v['pattern']}")
        print(f"  Message: {v['message']}")
    
    sys.exit(0 if result['status'] == 'PASS' else 1)

if __name__ == '__main__':
    main()
