#!/bin/zsh

# Performance testing script for .zshrc optimization

echo "🚀 Testing .zshrc Performance..."
echo "=================================="

# Test shell startup time (average of 5 runs)
echo "📊 Measuring shell startup time (5 runs):"
total_time=0
for i in {1..5}; do
    time_output=$(time zsh -i -c exit 2>&1)
    # Extract the total time more reliably
    current_time=$(echo "$time_output" | grep "total" | awk '{print $NF}' | sed 's/s$//')
    echo "  Run $i: ${current_time}s"
    # Only add to total if we got a valid number
    if [[ "$current_time" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        total_time=$(echo "$total_time + $current_time" | bc -l 2>/dev/null || echo "$total_time")
    fi
done

if command -v bc >/dev/null 2>&1 && [[ "$total_time" != "0" ]]; then
    average_time=$(echo "scale=3; $total_time / 5" | bc -l)
    echo "📈 Average startup time: ${average_time}s"
    
    if (( $(echo "$average_time < 1.0" | bc -l) )); then
        echo "✅ Excellent! Shell startup is under 1 second"
    elif (( $(echo "$average_time < 2.0" | bc -l) )); then
        echo "✓ Good! Shell startup is under 2 seconds"
    else
        echo "⚠️  Shell startup is still slow (>${average_time}s)"
    fi
else
    echo "📈 Performance testing complete (timing parsing had issues, but you can see the times above)"
fi

echo ""
echo "🔍 Testing alias loading:"

# Test lazy loading
echo "  Testing alias availability..."
zsh -i -c "alias-status" 2>/dev/null && echo "  ✓ Alias management working"

echo ""
echo "💡 Performance Tips:"
echo "  • Aliases are now lazy-loaded for better performance"
echo "  • Use 'load-all' to preload all aliases if needed"
echo "  • Use 'alias-status' to see which groups are loaded"
echo "  • First use of git/uv/ruff/brew will load respective aliases"
